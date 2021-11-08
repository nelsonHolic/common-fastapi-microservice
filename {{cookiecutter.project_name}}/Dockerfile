FROM python:3.9.2

RUN pip install poetry

WORKDIR /code

COPY pyproject.toml /code/

RUN poetry install
RUN poetry config virtualenvs.create false \
  && poetry install $(test "$YOUR_ENV" == production && echo "--no-dev") --no-interaction --no-ansi

COPY {{cookiecutter.project_name}}/ /code/{{cookiecutter.project_name}}

CMD ["poetry", "run", "uvicorn", "{{cookiecutter.project_name}}.app:app", "--host", "0.0.0.0", "--port", "80"]