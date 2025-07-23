import os
import shutil
from pathlib import Path
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import UploadFile, HTTPException
from app.models.file import File
from app.models.project import Project
from app.core.config import settings

UPLOAD_DIR = Path("uploads")


class FileService:
    def __init__(self, db: Session):
        self.db = db
        # Ensure upload directory exists
        UPLOAD_DIR.mkdir(exist_ok=True)

    def upload_file(self, project_id: int, file: UploadFile, user_id: int) -> File:
        """Upload a file to a project"""
        # Check if project exists
        project = self.db.query(Project).filter(Project.id == project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")

        # Validate file size (10MB limit)
        if file.size and file.size > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File too large")

        # Create unique filename
        file_extension = Path(file.filename).suffix
        unique_filename = f"{project_id}_{user_id}_{file.filename}"
        file_path = UPLOAD_DIR / unique_filename

        # Save file to disk
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Create file record
        db_file = File(
            filename=unique_filename,
            original_filename=file.filename,
            file_path=str(file_path),
            file_size=file.size or 0,
            mime_type=file.content_type or "application/octet-stream",
            project_id=project_id,
            uploaded_by=user_id
        )

        self.db.add(db_file)
        self.db.commit()
        self.db.refresh(db_file)

        return db_file

    def get_project_files(self, project_id: int) -> List[File]:
        """Get all files for a project"""
        return self.db.query(File).filter(File.project_id == project_id).all()

    def get_file(self, file_id: int) -> Optional[File]:
        """Get a specific file by ID"""
        return self.db.query(File).filter(File.id == file_id).first()

    def download_file(self, file_id: int) -> Optional[dict]:
        """Get file data for download"""
        file_obj = self.get_file(file_id)
        if not file_obj or not os.path.exists(file_obj.file_path):
            return None

        return {
            "path": file_obj.file_path,
            "filename": file_obj.original_filename,
            "mime_type": file_obj.mime_type
        }

    def delete_file(self, file_id: int, user_id: int) -> bool:
        """Delete a file"""
        file_obj = self.get_file(file_id)
        if not file_obj:
            return False

        # Check if user owns the file or is project owner
        if file_obj.uploaded_by != user_id:
            # Check if user is project owner
            project = self.db.query(Project).filter(
                Project.id == file_obj.project_id
            ).first()
            if not project or project.owner_id != user_id:
                return False

        # Delete file from disk
        if os.path.exists(file_obj.file_path):
            os.remove(file_obj.file_path)

        # Delete from database
        self.db.delete(file_obj)
        self.db.commit()

        return True

    def update_file(self, file_id: int, user_id: int, description: str) -> Optional[File]:
        """Update file description"""
        file_obj = self.get_file(file_id)
        if not file_obj or file_obj.uploaded_by != user_id:
            return None

        file_obj.description = description
        self.db.commit()
        self.db.refresh(file_obj)

        return file_obj 