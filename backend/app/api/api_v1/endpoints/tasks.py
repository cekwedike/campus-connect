from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.schemas.task import Task, TaskCreate, TaskUpdate
from app.services.task_service import TaskService

router = APIRouter()

@router.post("/", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """Create a new task"""
    task_service = TaskService(db)
    return task_service.create_task(task)

@router.get("/", response_model=List[Task])
def get_tasks(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all tasks"""
    task_service = TaskService(db)
    return task_service.get_tasks(skip=skip, limit=limit)

@router.get("/project/{project_id}", response_model=List[Task])
def get_tasks_by_project(project_id: int, db: Session = Depends(get_db)):
    """Get all tasks for a specific project"""
    task_service = TaskService(db)
    return task_service.get_tasks_by_project(project_id)

@router.get("/{task_id}", response_model=Task)
def get_task(task_id: int, db: Session = Depends(get_db)):
    """Get a specific task by ID"""
    task_service = TaskService(db)
    task = task_service.get_task(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.put("/{task_id}", response_model=Task)
def update_task(task_id: int, task_update: TaskUpdate, db: Session = Depends(get_db)):
    """Update a task"""
    task_service = TaskService(db)
    task = task_service.update_task(task_id, task_update)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    """Delete a task"""
    task_service = TaskService(db)
    success = task_service.delete_task(task_id)
    if not success:
        raise HTTPException(status_code=404, detail="Task not found") 