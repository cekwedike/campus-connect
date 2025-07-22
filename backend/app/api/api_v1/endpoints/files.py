from typing import List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File as FastAPIFile, Form
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.services.file_service import FileService
from app.schemas.file import FileResponse, FileUpdate

router = APIRouter()


@router.post("/upload/{project_id}", response_model=FileResponse)
async def upload_file(
    project_id: int,
    file: UploadFile = FastAPIFile(...),
    description: str = Form(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upload a file to a project"""
    file_service = FileService(db)
    uploaded_file = file_service.upload_file(file, project_id, current_user.id, description)
    
    return FileResponse(
        id=uploaded_file.id,
        filename=uploaded_file.filename,
        original_filename=uploaded_file.original_filename,
        file_size=uploaded_file.file_size,
        mime_type=uploaded_file.mime_type,
        description=uploaded_file.description,
        project_id=uploaded_file.project_id,
        uploaded_by=uploaded_file.uploaded_by,
        created_at=uploaded_file.created_at,
        download_url=f"/api/v1/files/download/{uploaded_file.id}"
    )


@router.get("/project/{project_id}", response_model=List[FileResponse])
async def get_project_files(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all files for a project"""
    file_service = FileService(db)
    files = file_service.get_project_files(project_id, current_user.id)
    
    return [
        FileResponse(
            id=file.id,
            filename=file.filename,
            original_filename=file.original_filename,
            file_size=file.file_size,
            mime_type=file.mime_type,
            description=file.description,
            project_id=file.project_id,
            uploaded_by=file.uploaded_by,
            created_at=file.created_at,
            download_url=f"/api/v1/files/download/{file.id}"
        )
        for file in files
    ]


@router.get("/{file_id}", response_model=FileResponse)
async def get_file(
    file_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get a specific file"""
    file_service = FileService(db)
    file = file_service.get_file(file_id, current_user.id)
    
    return FileResponse(
        id=file.id,
        filename=file.filename,
        original_filename=file.original_filename,
        file_size=file.file_size,
        mime_type=file.mime_type,
        description=file.description,
        project_id=file.project_id,
        uploaded_by=file.uploaded_by,
        created_at=file.created_at,
        download_url=f"/api/v1/files/download/{file.id}"
    )


@router.get("/download/{file_id}")
async def download_file(
    file_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Download a file"""
    file_service = FileService(db)
    file = file_service.get_file(file_id, current_user.id)
    
    from fastapi.responses import FileResponse
    return FileResponse(
        path=file.file_path,
        filename=file.original_filename,
        media_type=file.mime_type
    )


@router.put("/{file_id}", response_model=FileResponse)
async def update_file(
    file_id: int,
    file_update: FileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update file description"""
    file_service = FileService(db)
    file = file_service.update_file(file_id, current_user.id, file_update)
    
    return FileResponse(
        id=file.id,
        filename=file.filename,
        original_filename=file.original_filename,
        file_size=file.file_size,
        mime_type=file.mime_type,
        description=file.description,
        project_id=file.project_id,
        uploaded_by=file.uploaded_by,
        created_at=file.created_at,
        download_url=f"/api/v1/files/download/{file.id}"
    )


@router.delete("/{file_id}")
async def delete_file(
    file_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a file"""
    file_service = FileService(db)
    file_service.delete_file(file_id, current_user.id)
    return {"message": "File deleted successfully"} 