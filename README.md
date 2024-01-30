# template-python
Web service template in Python for reuse.

## Installation
1. If you don't have `Poetry` installed run:

```bash
pip insatll poetry
```

2. Install dependencies:

```bash
poetry config virtualenvs.in-project true
poetry install --no-root --with dev,test
```

3. Install `pre-commit` hooks:

```bash
poetry run pre-commit install
```

4. Launch of the project:

```bash
poetry run uvicorn app.main:app [--reload]
```

5. Running tests:

```bash
poetry run pytest
```

## Docker
The image is automatically built in GitHub Actions after pushing code to the main branch.

You can build a docker image and create a container manually:

```bash
docker build . -t <image-name>:<image-tag>
docker run <image-name>:<image-tag>
```

https://docs.docker.com/

## Release
The release is automatically built in GitHub Actions and saved to branch gh-pages after updating the application version in the main branch.

Create the branch gh-pages and use it as a GitHub page.
The releases will be available at https://github.com/<workspace>/<project>/releases/download/<app>-<version>/<app>-<version>.tgz.
The index will be available at https://<workspace>.github.io/<project>/index.yaml.
You can use URL https://<workspace>.github.io/<project>/ on https://artifacthub.io/.

## Deploy
The release is automatically deployed to Kubernetes cluster in GitHub Actions after pushing code to the main branch.

You can deploy it manually:
Set up Kubernetes config to ~/.kube/config

```bash
helm repo add <repo-name> https://<workspace>.github.io/<project>/
helm upgrade --install my-app <repo-name>/app
```

https://helm.sh/ru/docs/

## GitHub Actions
GitHub Actions run tests, build and push a Docker image, creat and push a Helm chart release, deploy the project to Kubernetes cluster.

Setup env variable at https://github.com/<workspace>/<project>/settings/variables/actions:
1. DOCKER_IMAGE_NAME - The name of the Docker image for uploading to the repository.
2. HELM_REPO_URL - https://<workspace>.github.io/<project>/

Setup secrets at https://github.com/<workspace>/<project>/settings/secrets/actions:
1. DOCKER_USERNAME - The username for the Docker repository on https://hub.docker.com/.
2. DOCKER_PASSWORD - The password for the Docker repository.
3. KUBE_CONFIG - Kubernetes config in base64

https://docs.github.com/en/actions

# Collaboration guidelines
HIRO uses and requires from its partners [GitFlow with Forks](https://hirodevops.notion.site/GitFlow-with-Forks-3b737784e4fc40eaa007f04aed49bb2e?pvs=4)
