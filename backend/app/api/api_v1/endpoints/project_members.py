from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.schemas.project_member import (
    ProjectMember,
    ProjectMemberCreate,
    ProjectMemberUpdate,
)
from app.services.project_member_service import ProjectMemberService

router = APIRouter()


@router.post("/", response_model=ProjectMember, status_code=status.HTTP_201_CREATED)
def add_project_member(
    project_member: ProjectMemberCreate, db: Session = Depends(get_db)
):
    """Add a member to a project"""
    project_member_service = ProjectMemberService(db)
    return project_member_service.create_project_member(project_member)


@router.get("/project/{project_id}", response_model=List[ProjectMember])
def get_project_members(project_id: int, db: Session = Depends(get_db)):
    """Get all members of a project"""
    project_member_service = ProjectMemberService(db)
    return project_member_service.get_project_members(project_id)


@router.get("/user/{user_id}", response_model=List[ProjectMember])
def get_user_projects(user_id: int, db: Session = Depends(get_db)):
    """Get all projects a user is a member of"""
    project_member_service = ProjectMemberService(db)
    return project_member_service.get_user_projects(user_id)


@router.put("/project/{project_id}/user/{user_id}", response_model=ProjectMember)
def update_project_member_role(
    project_id: int,
    user_id: int,
    project_member_update: ProjectMemberUpdate,
    db: Session = Depends(get_db),
):
    """Update a project member's role"""
    project_member_service = ProjectMemberService(db)
    project_member = project_member_service.update_project_member(
        project_id, user_id, project_member_update
    )
    if not project_member:
        raise HTTPException(status_code=404, detail="Project member not found")
    return project_member


@router.delete(
    "/project/{project_id}/user/{user_id}", status_code=status.HTTP_204_NO_CONTENT
)
def remove_project_member(project_id: int, user_id: int, db: Session = Depends(get_db)):
    """Remove a member from a project"""
    project_member_service = ProjectMemberService(db)
    success = project_member_service.delete_project_member(project_id, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="Project member not found")
