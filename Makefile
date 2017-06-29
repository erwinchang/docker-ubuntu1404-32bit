all: build

build:
	@docker build --tag=erwinchang/docker-ubuntu1404-32bit:latest .

release: build
	@docker build --tag=erwinchang/docker-ubuntu1404-32bit:$(shell cat VERSION) .
