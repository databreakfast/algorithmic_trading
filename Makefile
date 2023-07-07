SHELL          := /bin/bash
REGISTRY       := dfkozlov
GIT_REPO       := $$(basename -s .git `git config --get remote.origin.url`)
GIT_BRANCH     := $$(if [ -n "$$BRANCH_NAME" ]; then echo "$$BRANCH_NAME"; else git rev-parse --abbrev-ref HEAD; fi)
GIT_BRANCH     := $$(echo "${GIT_BRANCH}" | tr '[:upper:]' '[:lower:]')
CONTAINER_NAME := vectorbt-full
GIT_SHA1       := $$(git rev-parse HEAD)
NAME           := ${REGISTRY}/${CONTAINER_NAME}
IMG            := "${NAME}:${GIT_REPO}-${GIT_BRANCH}-${GIT_SHA1}"
LATEST         := "${NAME}:latest"
DOCKER_CMD     := docker
VECTORBT_SHA1  := e1906ce86141777fe66ca84fa3276d7790f268dc

run:
	(${DOCKER_CMD} rm -f ${CONTAINER_NAME} || true) && \
	${DOCKER_CMD} run --rm -p 8888:8888 -v $$(pwd):/home/jovyan/work --name ${CONTAINER_NAME} ${LATEST}

build:
	@ set -ex; \
	${DOCKER_CMD} build --build-arg TEST=true -t ${IMG} -t ${LATEST} .

clean-build:
	@ set -ex; \
	rm -rf *.zip && \
	rm -rf vectorbt* && \
	wget https://github.com/polakowo/vectorbt/archive/${VECTORBT_SHA1}.zip && \
	unzip ${VECTORBT_SHA1}.zip && \
	mv vectorbt-${VECTORBT_SHA1} vectorbt && \
	${DOCKER_CMD} build --build-arg TEST=true -t ${IMG} -t ${LATEST} .

push:
	${DOCKER_CMD} push ${LATEST}
	${DOCKER_CMD} push ${IMG}

