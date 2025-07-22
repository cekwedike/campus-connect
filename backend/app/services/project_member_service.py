from sqlalchemy.orm import Session
from app.models.project_member import ProjectMember, MemberRole
from app.schemas.project_member import ProjectMemberCreate, ProjectMemberUpdate
from typing import List


class ProjectMemberService:
    def __init__(self, db: Session):
        self.db = db

    def create_project_member(self, project_member: ProjectMemberCreate) -> ProjectMember:
        db_project_member = ProjectMember(
            project_id=project_member.project_id,
            user_id=project_member.user_id,
            role=project_member.role,
        )
        self.db.add(db_project_member)
        self.db.commit()
        self.db.refresh(db_project_member)
        return db_project_member

    def get_project_members(self, project_id: int) -> List[ProjectMember]:
        return self.db.query(ProjectMember).filter(
            ProjectMember.project_id == project_id
        ).all()

    def get_user_projects(self, user_id: int) -> List[ProjectMember]:
        return self.db.query(ProjectMember).filter(
            ProjectMember.user_id == user_id
        ).all()

    def get_project_member(self, project_id: int, user_id: int) -> ProjectMember:
        return self.db.query(ProjectMember).filter(
            ProjectMember.project_id == project_id,
            ProjectMember.user_id == user_id
        ).first()

    def update_project_member(self, project_id: int, user_id: int, project_member_update: ProjectMemberUpdate) -> ProjectMember:
        db_project_member = self.get_project_member(project_id, user_id)
        if not db_project_member:
            return None

        update_data = project_member_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_project_member, field, value)

        self.db.commit()
        self.db.refresh(db_project_member)
        return db_project_member

    def delete_project_member(self, project_id: int, user_id: int) -> bool:
        db_project_member = self.get_project_member(project_id, user_id)
        if not db_project_member:
            return False

        self.db.delete(db_project_member)
        self.db.commit()
        return True

    def is_project_member(self, project_id: int, user_id: int) -> bool:
        return self.get_project_member(project_id, user_id) is not None

    def is_project_admin(self, project_id: int, user_id: int) -> bool:
        member = self.get_project_member(project_id, user_id)
        return member and member.role in [MemberRole.OWNER, MemberRole.ADMIN] 