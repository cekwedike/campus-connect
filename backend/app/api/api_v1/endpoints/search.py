from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.project import Project
from app.models.task import Task
from app.models.project_member import ProjectMember
from app.schemas.project import ProjectResponse
from app.schemas.task import TaskResponse
from app.schemas.user import UserResponse

router = APIRouter()


@router.get("/projects", response_model=List[ProjectResponse])
async def search_projects(
    q: str = Query(..., description="Search query"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Search projects by title or description"""
    
    # Search in user's own projects and projects they're a member of
    projects = db.query(Project).join(
        ProjectMember, 
        or_(
            Project.id == ProjectMember.project_id,
            Project.owner_id == current_user.id
        )
    ).filter(
        and_(
            ProjectMember.user_id == current_user.id,
            or_(
                Project.title.ilike(f"%{q}%"),
                Project.description.ilike(f"%{q}%")
            )
        )
    ).distinct().all()
    
    return [
        ProjectResponse(
            id=project.id,
            title=project.title,
            description=project.description,
            owner_id=project.owner_id,
            created_at=project.created_at,
            updated_at=project.updated_at
        )
        for project in projects
    ]


@router.get("/tasks", response_model=List[TaskResponse])
async def search_tasks(
    q: str = Query(..., description="Search query"),
    project_id: Optional[int] = Query(None, description="Filter by project ID"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Search tasks by title or description"""
    
    query = db.query(Task).join(Project).join(ProjectMember).filter(
        ProjectMember.user_id == current_user.id
    )
    
    if project_id:
        query = query.filter(Task.project_id == project_id)
    
    tasks = query.filter(
        or_(
            Task.title.ilike(f"%{q}%"),
            Task.description.ilike(f"%{q}%")
        )
    ).all()
    
    return [
        TaskResponse(
            id=task.id,
            title=task.title,
            description=task.description,
            status=task.status,
            project_id=task.project_id,
            assigned_to=task.assigned_to,
            due_date=task.due_date,
            created_at=task.created_at,
            updated_at=task.updated_at
        )
        for task in tasks
    ]


@router.get("/users", response_model=List[UserResponse])
async def search_users(
    q: str = Query(..., description="Search query"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Search users by username, full name, or email"""
    
    users = db.query(User).filter(
        and_(
            User.id != current_user.id,  # Exclude current user
            or_(
                User.username.ilike(f"%{q}%"),
                User.full_name.ilike(f"%{q}%"),
                User.email.ilike(f"%{q}%")
            )
        )
    ).limit(20).all()  # Limit results
    
    return [
        UserResponse(
            id=user.id,
            username=user.username,
            email=user.email,
            full_name=user.full_name,
            profile_image=user.profile_image,
            created_at=user.created_at
        )
        for user in users
    ]


@router.get("/global", response_model=dict)
async def global_search(
    q: str = Query(..., description="Search query"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Global search across projects, tasks, and users"""
    
    # Search projects
    projects = db.query(Project).join(ProjectMember).filter(
        and_(
            ProjectMember.user_id == current_user.id,
            or_(
                Project.title.ilike(f"%{q}%"),
                Project.description.ilike(f"%{q}%")
            )
        )
    ).limit(5).all()
    
    # Search tasks
    tasks = db.query(Task).join(Project).join(ProjectMember).filter(
        and_(
            ProjectMember.user_id == current_user.id,
            or_(
                Task.title.ilike(f"%{q}%"),
                Task.description.ilike(f"%{q}%")
            )
        )
    ).limit(5).all()
    
    # Search users
    users = db.query(User).filter(
        and_(
            User.id != current_user.id,
            or_(
                User.username.ilike(f"%{q}%"),
                User.full_name.ilike(f"%{q}%")
            )
        )
    ).limit(5).all()
    
    return {
        "projects": [
            {
                "id": project.id,
                "title": project.title,
                "description": project.description[:100] + "..." if len(project.description) > 100 else project.description
            }
            for project in projects
        ],
        "tasks": [
            {
                "id": task.id,
                "title": task.title,
                "description": task.description[:100] + "..." if len(task.description) > 100 else task.description,
                "status": task.status,
                "project_id": task.project_id
            }
            for task in tasks
        ],
        "users": [
            {
                "id": user.id,
                "username": user.username,
                "full_name": user.full_name
            }
            for user in users
        ]
    } 