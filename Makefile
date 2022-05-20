.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: up
up: ## Up application
	docker-compose up --build --remove-orphans --abort-on-container-exit -t 0 app db


.PHONY: test
test: ## Run tests in the docker environment
	docker-compose up --build -d db
	docker-compose build dev
	docker-compose run --rm dev sh -c "PYTHONPATH=./app pytest ./tests/"
	docker-compose down --remove-orphans -t 0


.PHONY: lint
lint: ## Run linters in the docker environment
	docker-compose build dev
	docker-compose run --rm dev pre-commit run -a
	docker-compose down --remove-orphans -t 0


.PHONY: down
down: ## Stop development environment
	docker-compose down --remove-orphans -t 0
