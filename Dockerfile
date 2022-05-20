FROM python:3.10-slim AS builder
ENV PATH=/root/.poetry/bin:$PATH
WORKDIR /code
ADD https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py ./get-poetry.py

RUN apt-get update \
 && apt-get install --no-install-recommends -y git \
 && rm -rf /var/lib/apt/lists/* \
 && python get-poetry.py \
 && rm get-poetry.py

COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false \
 && poetry install --no-dev --no-root --no-interaction --no-ansi


FROM builder AS dev
RUN poetry install --no-root --no-interaction --no-ansi

ADD https://github.com/hadolint/hadolint/releases/download/v2.7.0/hadolint-Linux-x86_64 /bin/hadolint
RUN chmod +x /bin/hadolint

WORKDIR /app
COPY .pre-commit-config.yaml ./
RUN git init && pre-commit install-hooks
COPY ./ ./
RUN git add .


FROM python:3.10-slim AS app

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn
COPY ./app /app
USER nobody

EXPOSE 8085

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8085"]
