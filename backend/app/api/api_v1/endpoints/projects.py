from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.schemas.project import Project, ProjectCreate, ProjectUpdate
from app.services.project_service import ProjectService

router = APIRouter()


@router.post("/", response_model=Project, status_code=status.HTTP_201_CREATED)
def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    """Create a new project"""
    project_service = ProjectService(db)
    # TODO: Get current user from authentication
    owner_id = 1  # Temporary hardcoded for now
    return project_service.create_project(project, owner_id)


@router.get("/", response_model=List[Project])
def get_projects(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all projects"""
    project_service = ProjectService(db)
    return project_service.get_projects(skip=skip, limit=limit)


@router.get("/{project_id}", response_model=Project)
def get_project(project_id: int, db: Session = Depends(get_db)):
    """Get a specific project by ID"""
    project_service = ProjectService(db)
    project = project_service.get_project(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@router.put("/{project_id}", response_model=Project)
def update_project(
    project_id: int, project_update: ProjectUpdate, db: Session = Depends(get_db)
):
    """Update a project"""
    project_service = ProjectService(db)
    project = project_service.update_project(project_id, project_update)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(project_id: int, db: Session = Depends(get_db)):
    """Delete a project"""
    project_service = ProjectService(db)
    success = project_service.delete_project(project_id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found")
