# Back-End Stack

Back-End Stack for Govhack dockerised. See `code/README.md` for information on the actual stack.

## Dev

### Build Docker Image

Builds a docker image based on Ubuntu 14.04 with dependencies needed for this project installed.

    sudo make build-dev

### Run Docker Image

This will start up a container and run an interactive bash shell.
When you exit bash the container will be automatically stopped and removed.

    sudo make run

Or to rebuild and then run:

    sudo make rebuildandrun

#### Exposed Ports

Port 5556 in the container is mapped to port 5556 on the host machine so you can browse the frontend on <http://localhost:5556/>.

#### Persistance

* Changes made to the files in the `/code` directory in the Docker container will be reflected in the `./code` directory outside the Docker container (and vice versa).
* Changes made to the MongoDB database (`/var/lib/mongodb`) will be saved to `./docker/${ENV}/db`.
* Any other file changes made inside the Docker container will be lost upon exiting the container.

## Prod

### Build Docker Image

Builds a docker image based on Ubuntu 14.04 with dependencies needed for this project installed.

    sudo make build-prod

### Run Docker Image

This will start up a container hosting the optimised versions of the project files on port 5556 of the host machine.

    sudo make serve

Or to rebuild the container image and then serve (will stop already running container first if needed) use:

    sudo make rebuildandserve

### SSH

To SSH into the running container use.

    sudo make ssh

Note that the SSH keys included are obviously not secure. To generate new keys use:

    make sshkeygen
