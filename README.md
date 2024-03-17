# django-lightsail-tutorial

## Local Development
### Introduction
The application and all other services integrated with it will be run in Docker cotainers locally. Even though there will be some effort and time spent with setting up the configurations, there are many benefits in doing so, such as the following.

1. Having a consistent environment between development and production. This results in being more confident in whatever you developed locally will be reproducible in production as Docker containers are portable and independent of the machine that runs it.
2. It also makes it easier to collaborate with other developers as the application is easily reproducible on their local machine, thanks to Docker containers.

To learn more about Docker, check out their [docs](https://docs.docker.com/get-started/overview/).

### Initial Setup
#### Application
Start off by creating a requirements.txt file in the root of the project directory and add the line `Django==x.x.x` where x.x.x is the version of Django you want to use for the project.

Next, create a `Dockerfile` for the Django app and a `compose.yaml` file for the orchestration of the different services that makes up the entire project. As of this point, we only need to define the Django app service.

Next, run the following command to create the Django project within the container, which will then be reflected in the project directory on our local machine.

`docker-compose run --rm app sh -c "django-admin startproject app ."`
Breaking the command above down, we have the following points that explains what it does. 
- `docker-compose`: This is the command-line tool used for defining and running multi-container Docker applications. It reads the `compose.yaml` file to configure the services.
- `run`: This sub-command instructs Docker Compose to run a one-time command in a service container. It starts the specified service container, executes the command, and then stops and removes the container, unless it's instructed not to remove it (which is the default behavior if the `--rm` flag is not used).
- `--rm`: This flag specifies that the container should be removed after it exits. This is particularly useful for temporary containers created to run a specific command. It helps in keeping the system clean by removing containers that are no longer needed.
- `app`: This is the name of the service defined in your `compose.yaml` file. In this context, it's the name of the service you want to run the command in.
- `sh -c`: This is part of the command that will be executed within the container. `sh -c` typically runs the subsequent string as a shell command inside the container.
- `"django-admin startproject app ."` is the command that is run within the docker container. This this case, it creates a project directory with the standard initial files.

At this point, we should be able to start up our app with command:
`docker-compose up --build` and can view the initial webpage on localhost:8000. We can, however, only create and display static pages on our app as we do not have a database set up.

#### Database
For the database, it is best to use a Docker container for it as well. This approach also has benefits similar to using a container for the Django app. In fact, it would be ideal to use a Docker container for any new services integrated into the project (e.g. e-mail service). 

For the initial setup, PostgreSQL database would be used. There are a few places we need to add / make changes, listed below.

1. DATABASES settings (settings.py)  
    ```
    import os

    omit other settings for brevity...

    DATABASES = {
        "default": {      
            "ENGINE": "django.db.backends.postgresql",
            "NAME": os.environ["POSTGRES_DB"],
            "USER": os.environ["POSTGRES_USER"],
            "PASSWORD": os.environ["POSTGRES_PASSWORD"],
            "HOST": os.environ["POSTGRES_HOST"],
            "PORT": os.environ["POSTGRES_PORT"],
        }
    }
    ```
2. Add the PostgreSQL image configurations in compose.yaml  
    ```
      app configurations...

      database:
        image: postgres:12-alpine
        volumes:
        - db-dev-data:/var/lib/postgresql/data
        environment:
        - POSTGRES_USER=${POSTGRES_USER}
        - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
        - POSTGRES_DB=${POSTGRES_DB}
        healthcheck:
        test:
            [
            "CMD",
            "pg_isready",
            "-q",
            "-d",
            "django-dev-db",
            "-U",
            "postgres"
            ]
        interval: 5s
        timeout: 5s
        retries: 5

    volumes:
    db-dev-data:
    ```

3. Define environment variables for the database settings  

    In the .env file, define the five environment variables listed below (see the [docs](https://hub.docker.com/_/postgres) to understand more on what values to use for each of the variables.    
    - POSTGRES_PASSWORD  
    - POSTGRES_USER  
    - POSTGRES_DB  
    - POSTGRES_HOST  
    - POSTGRES_PORT  

        The values defined here will be propagated to the app and database containers after defining the corresponding configurations below. 

    ##### app service
    Under the environment attribute of the django app service, add these new env vars to the list so that the application can read these values in `settings.py`.
    - POSTGRES_USER=${POSTGRES_USER}
    - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    - POSTGRES_DB=${POSTGRES_DB}
    - POSTGRES_HOST=${POSTGRES_HOST}
    - POSTGRES_PORT=${POSTGRES_PORT}

    ##### database service
    Under the environment attribute of the database service, the required env vars configurations has already been added in the previous snippet in the list.
    - POSTGRES_USER=${POSTGRES_USER}
    - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    - POSTGRES_DB=${POSTGRES_DB}

4. Install psycopg2-binary as a dependency

Finally, ensure that you have stopped any existing container for the app and run command: `docker-compose up --build`.
The database would have been able to run, connected to the Django app and ready to receive any new migrations.
