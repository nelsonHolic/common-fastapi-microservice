FROM python:3.9.2

RUN pip install poetry

WORKDIR /code

COPY pyproject.toml /code/

RUN poetry install
RUN poetry config virtualenvs.create false \
  && poetry install $(test "$YOUR_ENV" == production && echo "--no-dev") --no-interaction --no-ansi

COPY microservice/ /code/intent_detector_service

CMD ["poetry", "run", "uvicorn", "intent_detector_service.app:app", "--host", "0.0.0.0", "--port", "80"]