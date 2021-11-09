from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr

from {{cookiecutter.project_name}}.database import db_config
from {{cookiecutter.project_name}}.database.models import User

# to get a string like this run:
# openssl rand -hex 32
SECRET_KEY = "54a2066d7689c69a8e0ad5649433993507bc8621a0fa29604787cd4a90823a66"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: Optional[str] = None


class UserSchema(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None


class UserInDB(UserSchema):
    hashed_password: str


class UserPayload(BaseModel):
    username: str
    email: EmailStr
    full_name: Optional[str]
    password: str


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI()


def get_user_by_username(username: str, db_session: Session) -> Optional[User]:
    return db_session.query(User).filter(User.username == username).first()


def create_user(user_payload: UserPayload, db_session: Session) -> None:
    user = User(
        username=user_payload.username,
        password=get_password_hash(user_payload.password),
        email=user_payload.email,
        full_name=user_payload.full_name,
        age=10
    )
    db_session.add(user)
    db_session.commit()


def verify_password(plain_password, hashed_password) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password) -> str:
    return pwd_context.hash(password)


def get_user(username: Optional[str], db_session: Session) -> Optional[UserInDB]:
    user = get_user_by_username(username, db_session)
    if user is not None:
        return UserInDB(
            username=user.username,
            email=user.email,
            full_name=user.full_name,
            disabled=False,
            hashed_password=user.password
        )

    return None


def authenticate_user(username: str, password: str, db_session: Session):
    user = get_user(username, db_session)
    if not user:
        return False

    if not verify_password(password, user.hashed_password):
        return False
    return user


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def get_current_user(
    token: str = Depends(oauth2_scheme), db_session: Session = Depends(db_config.session)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(username=token_data.username, db_session=db_session)

    if user is None:
        raise credentials_exception
    return user


async def get_current_active_user(current_user: UserSchema = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user
