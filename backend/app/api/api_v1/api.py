from fastapi import APIRouter
from app.api.api_v1.endpoints import users, projects, tasks, project_members, auth

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
api_router.include_router(project_members.router, prefix="/project-members", tags=["project-members"])
