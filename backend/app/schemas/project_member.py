from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.project_member import MemberRole
from pydantic import ConfigDict


class ProjectMemberBase(BaseModel):
    role: MemberRole = MemberRole.MEMBER


class ProjectMemberCreate(ProjectMemberBase):
    user_id: int
    project_id: int


class ProjectMemberUpdate(BaseModel):
    role: Optional[MemberRole] = None


class ProjectMember(ProjectMemberBase):
    id: int
    project_id: int
    user_id: int
    joined_at: datetime

    model_config = ConfigDict(from_attributes=True)
