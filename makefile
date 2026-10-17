.PHONY: install run test lint format typecheck check clean shell add update lock deploy

# Установить зависимости из poetry.lock
install:
	poetry install

# Установить + обновить lock-файл при изменении pyproject.toml
lock:
	poetry lock

# Добавить новый пакет (использование: make add pkg=requests)
add:
	poetry add $(pkg)

# Добавить dev-зависимость (использование: make add-dev pkg=ruff)
add-dev:
	poetry add --group dev $(pkg)

# Обновить все зависимости
update:
	poetry update

# Создать новую миграцию (использование: make migrate m="описание")
migrate:
	poetry run alembic revision --autogenerate -m "$(m)"

# Запустить приложение
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

.PHONY: run $(ARGS)

run:
	poetry run python $(ARGS)

$(ARGS):
	@:
# Зайти в shell окружения poetry
shell:
	poetry shell


# Линтер + автофикс (ruff умеет и то, и другое)
lint:
	poetry run ruff check . --fix

# Форматирование (ruff format заменяет black)
format:
	poetry run ruff format .

# Проверка типов
typecheck:
	poetry run mypy .

# Прогнать всё разом перед коммитом/пушем
check: lint format typecheck test

# Очистка кэшей
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage src/.mypy_cache

# Запуск контейнеров
docker:
	docker compose up -d

# Быстрый коммит + пуш в main (использование: make deploy m="описание коммита")
deploy:
	@if [ -z "$(m)" ]; then echo "Ошибка: укажи описание коммита. Пример: make deploy m=\"fix: исправлен баг\""; exit 1; fi
	git add -A
	git commit -m "$(m)"
	git push origin master
