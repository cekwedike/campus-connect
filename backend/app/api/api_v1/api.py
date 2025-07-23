from fastapi import APIRouter
from app.api.api_v1.endpoints import (
    users, projects, tasks, auth, project_members, files, search
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
api_router.include_router(
    project_members.router, prefix="/project-members", tags=["project-members"]
)
api_router.include_router(files.router, prefix="/files", tags=["files"])
api_router.include_router(search.router, prefix="/search", tags=["search"])
