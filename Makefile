.PHONY: help
help: ## help 表示 `make help` でタスクの一覧を確認できます
	@echo "------- タスク一覧 ------"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-20s\033[0m %s\n", $$1, $$2}'

BRANCH_NAME       := $(shell git name-rev --name-only   HEAD)
COMMIT_HASH       := $(shell git rev-parse --short HEAD)
CURRENT_TIMESTAMP := $(shell date +%Y-%m-%d-%H%M%S)
VERSION           := $(CURRENT_TIMESTAMP).$(subst /,_,$(BRANCH_NAME)).$(COMMIT_HASH)

## ---- go ---
BIN_DIR 		    = bin
BIN_NAME            = hello
GO_APP_FILES        := $(shell find . -type f -name '*.go')
## ---- docker ----
IMAGE_PATH             := koh789/k8s-trial-hello
DOCKER_FILE            := Dockerfile
DOCKER_VERSION         := $(CURRENT_TIMESTAMP)
DOCKER_VERSION_FILE    := Version
DOCKER_CURRENT_VERSION = $(shell cat $(VERSION_FILE))

## ----------- go -----------

.PHONY: build
build: build/$(BIN_NAME)  ## binary file build

build/$(BIN_NAME): 
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0  \
	go build -trimpath -tags netgo -ldflags='-s -w -extldflags "-static" -X "main.Version=$(VERSION)"' -o $@ 
	
## ----------- Docker -----------

docker-build: ## Docker Imageをbuildする
	docker build . -f $(DOCKER_FILE) -t $(IMAGE_PATH):$(DOCKER_VERSION)
	docker tag $(IMAGE_PATH):$(DOCKER_VERSION_FILE) $(IMAGE_PATH):latest
	echo $(DOCKER_VERSION) > $(VERSION_FILE)

docker-push: ## Docker ImageをGCRにpushする
	docker push $(IMAGE_PATH):$(DOCKER_CURRENT_VERSION)
	docker push $(IMAGE_PATH):latest
