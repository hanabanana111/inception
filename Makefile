LOGIN = hakobori
DATA_PATH = /home/$(LOGIN)/data
COMPOSE_FILE = srcs/docker-compose.yml

.PHONY: all setup stop down re clean fclean

all: setup
	@echo "[all] Building and starting containers..."
	docker compose -f $(COMPOSE_FILE) up --build -d

setup:
	@echo "[setup] Creating host data directories..."
	mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

stop:
	@echo "[stop] Stopping containers..."
	docker compose -f $(COMPOSE_FILE) stop

down:
	@echo "[down] Bringing down containers..."
	docker compose -f $(COMPOSE_FILE) down

re:
	@echo "[re] Rebuilding environment from scratch..."
	$(MAKE) fclean
	$(MAKE) all

clean: down
	@echo "[clean] Removing unused Docker images and resources..."
	docker system prune -a

fclean: clean
	@echo "[fclean] Removing persistent data directory..."
	sudo rm -rf $(DATA_PATH)
	@echo "[fclean] Removing all Docker volumes..."
	docker volume rm $$(docker volume ls -q)
