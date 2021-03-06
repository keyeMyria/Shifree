from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker
from config import database

db = SQLAlchemy()

DATABASE = 'mysql+mysqlconnector://%s:%s@%s:%s/%s' % (
        database['username'],
        database['password'],
        database['host'],
        database['port'],
        database['name']
    )

ENGINE = create_engine(
    DATABASE,
    encoding="utf-8",
    echo=False,
    pool_recycle=14400
)

session = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=ENGINE, expire_on_commit=False))


def init_db(app):
    db.init_app(app)
    Migrate(app, db)
