.PHONY: help
help: ## help 表示 `make help` でタスクの一覧を確認できます
	@echo "------- タスク一覧 ------"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-20s\033[0m %s\n", $$1, $$2}'

BRANCH_NAME       := $(shell git name-rev --name-only   HEAD)
COMMIT_HASH       := $(shell git rev-parse --short HEAD)
CURRENT_TIMESTAMP := $(shell date +%Y-%m-%d-%H%M%S)
VERSION           := $(CURRENT_TIMESTAMP).$(subst /,_,$(BRANCH_NAME)).$(COMMIT_HASH)
VERSION_FILE      := Version

## ---- go ---
BIN_DIR 		    = bin
BIN_NAME            = hello
GO_APP_FILES        := $(shell find . -type f -name '*.go')
## ---- docker ----
IMAGE_NAME   := koh789/k8s-trial/$(BIN_NAME)
IMAGE_TAG    ?= $(shell cat $(VERSION_FILE))
IMAGE_PATH    = $(IMAGE_NAME):$(IMAGE_TAG)
DOCKER_FILE   = Dockerfile

## ----------- go -----------
go-build:  ## binary file build
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0  \
	go build -trimpath -tags netgo -ldflags='-s -w -extldflags "-static" -X "main.Version=$(VERSION)"' -o $(BIN_DIR)/$(BIN_NAME)
	@$(MAKE) write-version 

write-version:
	@echo $(VERSION) > $(VERSION_FILE)
	
## ----------- Docker -----------

docker-build: ## Docker Imageをbuildする
	@echo "BIN_NAME: $(BIN_NAME)"
	docker  build -t $(IMAGE_PATH)  --build-arg APP=$(BIN_NAME) . -f $(DOCKER_FILE)

docker-push: ## Docker ImageをGCRにpushする
	docker push $(IMAGE_PATH)

docker-clean: ## 直近2件のimageを残して、その他のイメージを削除する
	@docker images --format "{{.ID}}\t{{.CreatedAt}}\t{{.Tag}}" $(IMAGE_PATH) \
		| sort -r -k2,3 \
		| awk '$$3 != "latest" && NR > 3 {print $$1}' \
		| xargs -n 1 docker rmi -f