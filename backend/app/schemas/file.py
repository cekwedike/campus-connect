from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class FileBase(BaseModel):
    filename: str
    original_filename: str
    file_size: int
    mime_type: str
    description: Optional[str] = None
    project_id: int


class FileCreate(FileBase):
    pass


class FileUpdate(BaseModel):
    description: Optional[str] = None


class File(FileBase):
    id: int
    uploaded_by: int
    created_at: datetime

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

    class Config:
        from_attributes = True
