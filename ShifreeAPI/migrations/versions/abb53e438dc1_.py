"""empty message

Revision ID: abb53e438dc1
Revises: 211dcd0f91c8
Create Date: 2018-06-18 05:16:47.789245

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'abb53e438dc1'
down_revision = '211dcd0f91c8'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('user', sa.Column('order', sa.Integer(), nullable=False))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('user', 'order')
    # ### end Alembic commands ###
