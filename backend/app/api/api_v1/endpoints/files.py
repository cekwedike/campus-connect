from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.auth import get_current_user
from app.schemas.file import File as FileSchema, FileCreate
from app.services.file_service import FileService
from app.models.user import User

router = APIRouter()


@router.post("/upload/{project_id}", response_model=FileSchema)
def upload_file(
    project_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upload a file to a project"""
    file_service = FileService(db)
    return file_service.upload_file(project_id, file, current_user.id)


@router.get("/project/{project_id}", response_model=List[FileSchema])
def get_project_files(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all files for a project"""
    file_service = FileService(db)
    return file_service.get_project_files(project_id)


@router.get("/{file_id}", response_model=FileSchema)
def get_file(
    file_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get a specific file by ID"""
    file_service = FileService(db)
    file_obj = file_service.get_file(file_id)
    if not file_obj:
        raise HTTPException(status_code=404, detail="File not found")
    return file_obj


@router.delete("/{file_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_file(
    file_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a file"""
    file_service = FileService(db)
    success = file_service.delete_file(file_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="File not found")


@router.get("/download/{file_id}")
def download_file(
    file_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Download a file"""
    file_service = FileService(db)
    file_data = file_service.download_file(file_id)
    if not file_data:
        raise HTTPException(status_code=404, detail="File not found")
    return file_data 