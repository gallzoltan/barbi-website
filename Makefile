CURRENT_DIR = $(shell pwd)
CONTAINER_NAME = dev-js
IMAGE_NAME = vnode18
HOST_PORT = 5173
CONTAINER_PORT = 5173

.PHONY: venv

venv:
	podman run --rm -it\
	 --name $(CONTAINER_NAME)\
	 -v $(CURRENT_DIR):/home/app\
	 -e RUN_PORT=$(CONTAINER_PORT)\
	 -p $(HOST_PORT):$(CONTAINER_PORT) \
	 $(IMAGE_NAME)