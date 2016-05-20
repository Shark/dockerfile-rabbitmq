NS = sh4rk
REPO = rabbitmq
VERSION ?= latest

default: deps build

deps:
	docker pull ubuntu:xenial

build:
	docker build -t $(NS)/$(REPO):$(VERSION) --force-rm=true .
