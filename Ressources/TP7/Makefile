.PHONY: all
all: build

.PHONY: build
build:
	cd ./configure && make || true && cd ..
	cd ./lab02/server && make || true && cd ..
	cd ./lab02/client && make || true && cd ..


.PHONY: lint
lint:
	cd ./oalib && make lint || true && cd ..
	cd ./lab02/server && make lint || true && cd ..
	cd ./lab02/client && make lint || true && cd ..


.PHONY: docker
docker:
	docker compose -f ./docker-compose.yaml build --parallel

.PHONY: labs
labs:
	docker compose -f ./docker-compose.yaml up -d

.PHONY: lab02
lab02:
	docker compose -f ./docker-compose.yaml up -d server-02 client-02

.PHONY: labsdown
labsdown:
	docker compose -f ./docker-compose.yaml down -v

.PHONY: devup
devup:
	docker compose -f ./docker-compose.dev.yaml up -d

.PHONY: devdown
devdown:
	docker compose -f ./docker-compose.dev.yaml down -v

.PHONY: config
config:
	cd ./configure && make && cd ..
	./configure/bin/configure

.PHONY: configure
configure:
	cd ./configure && make && cd ..
	./configure/bin/configure
