from sqlalchemy.orm import Session
from app.models.project import Project
from app.schemas.project import ProjectCreate, ProjectUpdate


class ProjectService:
    def __init__(self, db: Session):
        self.db = db

    def create_project(self, project: ProjectCreate, owner_id: int) -> Project:
        db_project = Project(
            title=project.title, description=project.description, owner_id=owner_id
        )
        self.db.add(db_project)
        self.db.commit()
        self.db.refresh(db_project)
        return db_project

    def get_projects(self, skip: int = 0, limit: int = 100):
        return self.db.query(Project).offset(skip).limit(limit).all()

    def get_user_projects(self, user_id: int, skip: int = 0, limit: int = 100):
        return self.db.query(Project).filter(Project.owner_id == user_id).offset(skip).limit(limit).all()

    def get_project(self, project_id: int):
        return self.db.query(Project).filter(Project.id == project_id).first()

    def update_project(self, project_id: int, project_update: ProjectUpdate):
        db_project = self.get_project(project_id)
        if not db_project:
            return None

        update_data = project_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_project, field, value)

        self.db.commit()
        self.db.refresh(db_project)
        return db_project

    def delete_project(self, project_id: int) -> bool:
        db_project = self.get_project(project_id)
        if not db_project:
            return False

        self.db.delete(db_project)
        self.db.commit()
        return True
