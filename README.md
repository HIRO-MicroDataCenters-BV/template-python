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
