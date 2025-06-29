from sqlalchemy.orm import Session
from app.models.task import Task
from app.schemas.task import TaskCreate, TaskUpdate

class TaskService:
    def __init__(self, db: Session):
        self.db = db
    
    def create_task(self, task: TaskCreate) -> Task:
        db_task = Task(
            title=task.title,
            description=task.description,
            status=task.status,
            project_id=task.project_id,
            assigned_to=task.assigned_to,
            due_date=task.due_date
        )
        self.db.add(db_task)
        self.db.commit()
        self.db.refresh(db_task)
        return db_task
    
    def get_tasks(self, skip: int = 0, limit: int = 100):
        return self.db.query(Task).offset(skip).limit(limit).all()
    
    def get_tasks_by_project(self, project_id: int):
        return self.db.query(Task).filter(Task.project_id == project_id).all()
    
    def get_task(self, task_id: int):
        return self.db.query(Task).filter(Task.id == task_id).first()
    
    def update_task(self, task_id: int, task_update: TaskUpdate):
        db_task = self.get_task(task_id)
        if not db_task:
            return None
        
        update_data = task_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_task, field, value)
        
        self.db.commit()
        self.db.refresh(db_task)
        return db_task
    
    def delete_task(self, task_id: int) -> bool:
        db_task = self.get_task(task_id)
        if not db_task:
            return False
        
        self.db.delete(db_task)
        self.db.commit()
        return True 