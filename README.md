# template-python
Web service template in Python for reuse.

## Installing dependencies
`poetry install --no-root`

## Using the virtual environment
`poetry shell`

## Set up GIT hooks for development
`pre-commit install`

## Launch of the project
`uvicorn app.main:app [--reload]`

The project will be launched at http://127.0.0.1:8000
REST API documentation will be available at http://127.0.0.1:8000/docs

## Running tests
`pytest`

## Creating and running a Docker Image
`docker build -t myimage .`
`docker build -t myimage --target test .`
`docker run -d --name mycontainer -p 80:80 myimage`

## Deploy
### GitHub Actions
Add secrets:
* DOCKER_USERNAME
* DOCKER_PASSWORD
* DOCKER_IMAGE_NAME

### Kubernetes
???
