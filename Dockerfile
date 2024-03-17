FROM python:3.11.1-alpine3.17

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

COPY  ./requirements.txt /requirements.txt

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /requirements.txt

# look for executables in /py/bin first when commands  
# are executed inside the docker container
ENV PATH="/py/bin:$PATH"

COPY . /app

WORKDIR /app
