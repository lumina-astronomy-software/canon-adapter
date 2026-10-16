# === Config ===
VERSION     ?= $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "dev")
PLATFORM    := linux/arm/v7
BUILD_DIR   := .build
SBC_IP      ?= $(ORANGE_PI_ONE_IP_SSH)
SBC_USER    ?= $(ORANGE_PI_ONE_USER_SSH)
DEPLOY_PATH ?= /opt/canon-adapter
SBC_SSH     := ssh $(SBC_USER)@$(SBC_IP)
SBC_SCP     := scp -o StrictHostKeyChecking=no

dev:
	pnpm dev

# === Agent stack on Pi (docker compose) ===
up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f

# === Cross-compile for Orange Pi (ARMv7) ===
cross-setup:
	docker buildx create --name armbuilder --use 2>/dev/null || docker buildx use armbuilder
	docker buildx inspect --bootstrap

cross-build: $(BUILD_DIR)
	docker buildx build \
		--platform $(PLATFORM) \
		--build-arg APP_VERSION=$(VERSION) \
		-t lumina-astronomy-software/canon-adapter:latest \
		--output type=docker,dest=$(BUILD_DIR)/canon-adapter.tar \
		.
	@echo "Image: $(BUILD_DIR)/canon-adapter.tar (version: $(VERSION))"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

deploy-push:
	@echo "Loading adapter image on $(SBC_IP)..."
	cat $(BUILD_DIR)/canon-adapter.tar | $(SBC_SSH) "docker load"

deploy-config:
	$(SBC_SSH) "mkdir -p $(DEPLOY_PATH)"
	$(SBC_SCP) docker-compose.yml $(SBC_USER)@$(SBC_IP):$(DEPLOY_PATH)/
	$(SBC_SCP) .env $(SBC_USER)@$(SBC_IP):$(DEPLOY_PATH)/

deploy-start:
	$(SBC_SSH) "cd $(DEPLOY_PATH) && docker compose pull mediamtx && docker compose up -d"

deploy-stop:
	$(SBC_SSH) "cd $(DEPLOY_PATH) && docker compose down"

deploy-logs:
	$(SBC_SSH) "cd $(DEPLOY_PATH) && docker compose logs -f"

deploy-status:
	$(SBC_SSH) "cd $(DEPLOY_PATH) && docker compose ps"

deploy: cross-build deploy-push deploy-config deploy-start
	@echo "canon-adapter deployed to $(SBC_IP)"

setup-pi:
	$(SBC_SCP) scripts/setup-pi.sh $(SBC_USER)@$(SBC_IP):/tmp/
	$(SBC_SSH) "chmod +x /tmp/setup-pi.sh && /tmp/setup-pi.sh"

load:
	docker load < $(BUILD_DIR)/canon-adapter.tar
	@echo "Loaded canon-adapter from $(BUILD_DIR)/canon-adapter.tar"

.PHONY: dev up down build logs cross-setup cross-build \
	deploy-push deploy-config deploy-start deploy-stop \
	deploy-logs deploy-status deploy setup-pi load
