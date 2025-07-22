from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from pydantic import ConfigDict


class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: str
    profile_image: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: Optional[str] = None
    profile_image: Optional[str] = None


class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
