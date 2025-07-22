"""Add profile_image to users table

Revision ID: 002
Revises: 001
Create Date: 2024-01-01 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '002'
down_revision = '001'
branch_labels = None
depends_on = None


def upgrade():
    # Add profile_image column to users table
    op.add_column('users', sa.Column('profile_image', sa.String(), nullable=True))


def downgrade():
    # Remove profile_image column from users table
    op.drop_column('users', 'profile_image') 