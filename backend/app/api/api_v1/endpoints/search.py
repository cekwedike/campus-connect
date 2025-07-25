from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.auth import get_current_user
from app.services.project_service import ProjectService
from app.services.task_service import TaskService
from app.services.user_service import UserService
from app.models.user import User as UserModel

router = APIRouter()


@router.get("/global")
def global_search(
    q: str,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    """Global search across projects, tasks, and users"""
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Search query too short")

    project_service = ProjectService(db)
    task_service = TaskService(db)
    user_service = UserService(db)

    # Search projects
    projects = project_service.search_projects(q, current_user.id)

    # Search tasks
    tasks = task_service.search_tasks(q, current_user.id)

    # Search users
    users = user_service.search_users(q)

    return {"projects": projects, "tasks": tasks, "users": users}


@router.get("/projects")
def search_projects(
    q: str,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    """Search projects"""
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Search query too short")

    project_service = ProjectService(db)
    projects = project_service.search_projects(q, current_user.id)

    return {"projects": projects}


@router.get("/tasks")
def search_tasks(
    q: str,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    """Search tasks"""
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Search query too short")

    task_service = TaskService(db)
    tasks = task_service.search_tasks(q, current_user.id)

    return {"tasks": tasks}


@router.get("/users")
def search_users(
    q: str,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    """Search users"""
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Search query too short")

    user_service = UserService(db)
    users = user_service.search_users(q)

    return {"users": users}
