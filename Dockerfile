FROM python:3.12-slim AS base

WORKDIR /code

COPY poetry.lock pyproject.toml ./

RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-root --without dev,test \
    && rm -rf $(poetry config cache-dir)/{cache,artifacts}

# Test
FROM base AS test
RUN poetry install --no-root --only dev,test \
    && rm -rf $(poetry config cache-dir)/{cache,artifacts}
COPY ./app /code/app

# Production
FROM base AS production
COPY ./app /code/app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
