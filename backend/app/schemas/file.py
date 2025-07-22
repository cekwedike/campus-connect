from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class FileBase(BaseModel):
    description: Optional[str] = None


class FileCreate(FileBase):
    project_id: int


class FileUpdate(FileBase):
    pass


class File(FileBase):
    id: int
    filename: str
    original_filename: str
    file_path: str
    file_size: int
    mime_type: str
    project_id: int
    uploaded_by: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class FileResponse(BaseModel):
    id: int
    filename: str
    original_filename: str
    file_size: int
    mime_type: str
    description: Optional[str] = None
    project_id: int
    uploaded_by: int
    created_at: datetime
    download_url: str 