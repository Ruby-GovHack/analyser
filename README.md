# Back-End Stack

Back-End Stack for Govhack dockerised. See code/README.md for information of the actual stack.

## Build Docker Image

Builds a docker image based on Ubuntu 14.04 with dependencies needed for this project installed.

    sudo make build

## Run Docker Image

This will start up a container and put you in an interactive bash shell.
When you exit bash the container will be automatically stopped and removed.

    sudo make run

### Persistance

Changes made to the files in the code directory will be reflected in the code directory outside the Docker container (and vice versa).
Any other changes made inside the Docker container however will be lost upon exiting the container.
