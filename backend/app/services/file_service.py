import os
import uuid
import shutil
from pathlib import Path
from typing import List, Optional
from fastapi import UploadFile, HTTPException
from sqlalchemy.orm import Session
from app.models.file import File
from app.models.project import Project
from app.models.user import User
from app.schemas.file import FileCreate, FileUpdate


class FileService:
    def __init__(self, db: Session):
        self.db = db
        self.upload_dir = Path("uploads")
        self.upload_dir.mkdir(exist_ok=True)

    def upload_file(
        self, 
        file: UploadFile, 
        project_id: int, 
        user_id: int, 
        description: Optional[str] = None
    ) -> File:
        """Upload a file to a project"""
        
        # Check if project exists and user has access
        project = self.db.query(Project).filter(Project.id == project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")
        
        # Check if user is a member of the project
        if project.owner_id != user_id:
            member = self.db.query(Project).join(Project.members).filter(
                Project.id == project_id,
                Project.members.any(id=user_id)
            ).first()
            if not member:
                raise HTTPException(status_code=403, detail="Access denied")

        # Validate file size (max 10MB)
        if file.size > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File too large. Maximum size is 10MB")

        # Validate file type
        allowed_types = [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'text/plain',
            'image/jpeg',
            'image/png',
            'image/gif',
            'application/zip',
            'application/x-rar-compressed'
        ]
        
        if file.content_type not in allowed_types:
            raise HTTPException(status_code=400, detail="File type not allowed")

        # Generate unique filename
        file_extension = Path(file.filename).suffix
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        
        # Create project directory
        project_dir = self.upload_dir / str(project_id)
        project_dir.mkdir(exist_ok=True)
        
        # Save file
        file_path = project_dir / unique_filename
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Create file record
        db_file = File(
            filename=unique_filename,
            original_filename=file.filename,
            file_path=str(file_path),
            file_size=file.size,
            mime_type=file.content_type,
            description=description,
            project_id=project_id,
            uploaded_by=user_id
        )
        
        self.db.add(db_file)
        self.db.commit()
        self.db.refresh(db_file)
        
        return db_file

    def get_project_files(self, project_id: int, user_id: int) -> List[File]:
        """Get all files for a project"""
        
        # Check if project exists and user has access
        project = self.db.query(Project).filter(Project.id == project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")
        
        # Check if user is a member of the project
        if project.owner_id != user_id:
            member = self.db.query(Project).join(Project.members).filter(
                Project.id == project_id,
                Project.members.any(id=user_id)
            ).first()
            if not member:
                raise HTTPException(status_code=403, detail="Access denied")

        files = self.db.query(File).filter(File.project_id == project_id).all()
        return files

    def get_file(self, file_id: int, user_id: int) -> File:
        """Get a specific file"""
        
        file = self.db.query(File).filter(File.id == file_id).first()
        if not file:
            raise HTTPException(status_code=404, detail="File not found")
        
        # Check if user has access to the project
        project = self.db.query(Project).filter(Project.id == file.project_id).first()
        if project.owner_id != user_id:
            member = self.db.query(Project).join(Project.members).filter(
                Project.id == file.project_id,
                Project.members.any(id=user_id)
            ).first()
            if not member:
                raise HTTPException(status_code=403, detail="Access denied")
        
        return file

    def delete_file(self, file_id: int, user_id: int) -> bool:
        """Delete a file"""
        
        file = self.db.query(File).filter(File.id == file_id).first()
        if not file:
            raise HTTPException(status_code=404, detail="File not found")
        
        # Check if user is the uploader or project owner
        project = self.db.query(Project).filter(Project.id == file.project_id).first()
        if file.uploaded_by != user_id and project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Access denied")
        
        # Delete physical file
        try:
            os.remove(file.file_path)
        except OSError:
            pass  # File might not exist
        
        # Delete database record
        self.db.delete(file)
        self.db.commit()
        
        return True

    def update_file(self, file_id: int, user_id: int, file_update: FileUpdate) -> File:
        """Update file description"""
        
        file = self.db.query(File).filter(File.id == file_id).first()
        if not file:
            raise HTTPException(status_code=404, detail="File not found")
        
        # Check if user is the uploader or project owner
        project = self.db.query(Project).filter(Project.id == file.project_id).first()
        if file.uploaded_by != user_id and project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Access denied")
        
        # Update file
        for field, value in file_update.dict(exclude_unset=True).items():
            setattr(file, field, value)
        
        self.db.commit()
        self.db.refresh(file)
        
        return file 