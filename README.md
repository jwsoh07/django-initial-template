# django-lightsail-tutorial

## Local Development
### Introduction
The application and all other services integrated with it will be run in Docker cotainers locally. Even though there will be some effort and time spent with setting up the configurations, there are many benefits in doing so, such as the following.

1. Having a consistent environment between development and production. This results in being more confident in whatever you developed locally will be reproducible in production as Docker containers are portable and independent of the machine that runs it.
2. It also makes it easier to collaborate with other developers as the application is easily reproducible on their local machine, thanks to Docker containers.

To learn more about Docker, check out their [docs](https://docs.docker.com/get-started/overview/).

### Setup
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
