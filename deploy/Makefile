CONTAINER_NAME=govhack-backend
IMAGE_NAME=${CONTAINER_NAME}-image

# The directory which contains this Makefile.
BUILD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

build:
	docker build -t ${IMAGE_NAME} .

run:
	docker run -i -t --rm --name="${CONTAINER_NAME}" --hostname="${CONTAINER_NAME}" -v "${BUILD_DIR}/../code:/code" -p 80:80 ${IMAGE_NAME}

rebuildandrun: build run
