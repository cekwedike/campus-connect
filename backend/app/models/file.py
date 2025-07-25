from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base


class File(Base):
    __tablename__ = "files"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=False)  # Stored filename
    original_filename = Column(String, nullable=False)  # Original filename
    file_path = Column(String, nullable=False)  # Path to file on disk
    file_size = Column(Integer, nullable=False)  # File size in bytes
    mime_type = Column(String, nullable=False)  # MIME type
    description = Column(Text, nullable=True)  # Optional description
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)
    uploaded_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    project = relationship("Project", back_populates="files")
    user = relationship("User", back_populates="uploaded_files")
