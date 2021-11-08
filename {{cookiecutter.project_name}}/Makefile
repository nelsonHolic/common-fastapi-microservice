PROJECT_NAME={{cookiecutter.project_name}}

.PHONY: no_targets__ list
no_targets__:
list:
	sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | sort"


git-changes:
	@ git diff ${BASE_BRANCH} --diff-filter=ACMR --name-only | (grep -E '.py$$' || true) | tr '\n' ' '

format:  ## Format (autoflake, isort, black) files modified relative to `origin/main`
	@ ( \
		export MODIFIED="$$(BASE_BRANCH=origin/main $(MAKE) -s git-changes)" && \
		if [ -z "$${MODIFIED}" ]; then echo "No files changed – no need to format"; exit; fi && \
		echo "Formatting python files:\n\n$${MODIFIED}\n" && \
		$(MAKE) format-all \
	)

format-pyupgrade:
	echo $${MODIFIED:-$$(find . -name "*.py")} | xargs python3 -m pyupgrade --py39-plus --exit-zero-even-if-changed

format-all: format-pyupgrade  ## Format all files
	python3 -m autoflake -r --in-place $${MODIFIED:-.}
	python3 -m isort --quiet $${MODIFIED:-. -rc}
	python3 -m black --quiet $${MODIFIED:-.}

lint: ## linting process
	@ python -m flake8 ${PROJECT_NAME}
	@ python -m pylint ${PROJECT_NAME}

mypy: ## Check typing
	@ python -m mypy

migration:
	./scripts/env.sh python3 -m alembic.config -c $(PROJECT_NAME)/database/alembic.ini revision --autogenerate -m "$$NAME"

migrate:
	./scripts/env.sh python3 -m alembic.config -c $(PROJECT_NAME)/database/alembic.ini upgrade head