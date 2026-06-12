LOGIN = hakobori
DATA_PATH = /home/$(LOGIN)/data
COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)
DATA_DIRS = $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

.PHONY: all setup stop down re clean fclean

all: setup
	@echo "[all] Building and starting containers..."
	@$(COMPOSE) up --build

setup:
	@echo "[setup] Ensuring host data directories exist..."
	@mkdir -p $(DATA_DIRS)

up:
	@echo "[up] Building and starting containers..."
	@$(COMPOSE) up

stop:
	@echo "[stop] Stopping containers..."
	@$(COMPOSE) stop

down:
	@echo "[down] Bringing down containers..."
	@$(COMPOSE) down --remove-orphans

re:
	@echo "[re] Rebuilding environment from scratch..."
	$(MAKE) fclean
	$(MAKE) all

clean:
	@echo "[clean] Removing containers and project images..."
	@$(COMPOSE) down --rmi all --remove-orphans

fclean: clean
	@echo "[fclean] Removing project volumes and host data directories..."
	@$(COMPOSE) down -v --rmi all --remove-orphans
	@rm -rf "$(DATA_PATH)/mariadb" "$(DATA_PATH)/wordpress"
