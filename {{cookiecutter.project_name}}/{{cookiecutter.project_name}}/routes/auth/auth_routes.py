from datetime import timedelta

from sqlalchemy.orm import Session
from fastapi import Depends, HTTPException, status, Response
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel

from {{cookiecutter.project_name}} import constants
from {{cookiecutter.project_name}}.database import db_config
from {{cookiecutter.project_name}}.routes.routers import auth
from {{cookiecutter.project_name}}.services.oauth import (
    authenticate_user, Token, ACCESS_TOKEN_EXPIRE_MINUTES,
    create_access_token, get_user_by_username, UserPayload, create_user,
)


@auth.post("/users")
async def create_user_endpoint(user_data: UserPayload, db_session: Session = Depends(db_config.session)) -> str:
    if get_user_by_username(user_data.username, db_session):
        raise HTTPException(status_code=403, detail="That username is already in used")

    create_user(user_data)

    return "success"


@auth.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),  db_session: Session = Depends(db_config.session)
):
    user = authenticate_user(form_data.username, form_data.password, db_session)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
