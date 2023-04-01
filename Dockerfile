ARG PYTHON_VERSION=3.11

FROM python:${PYTHON_VERSION}-slim AS python-base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV POETRY_HOME="/opt/poetry"
ENV PYTHON_SETUP_PATH="/opt/python_setup"
ENV PATH=${POETRY_HOME}/bin/:${PATH}


FROM python-base AS initial
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    curl \
    build-essential \
    git \
    cmake

RUN pip install poetry
WORKDIR ${PYTHON_SETUP_PATH}


FROM initial AS development-base
ENV POETRY_NO_INTERACTION=1
COPY poetry.lock* pyproject.toml* ./


FROM development-base AS development
RUN poetry install
WORKDIR /app


FROM development-base AS builder-base
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser
RUN poetry install --no-dev


FROM python-base AS production
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser
COPY --from=builder-base /usr/local/lib/python${PYTHON_VERSION}/site-packages /usr/local/lib/python${PYTHON_VERSION}/site-packages
COPY ./src /app/
WORKDIR /app

EXPOSE 8888

