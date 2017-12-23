# Running collateX inside a docker container

David J. Birnbaum and Ronald Haentjens Dekker  
Last revised 2017-12-23

## Rationale

[**CollateX**](https://pypi.python.org/pypi/collatex) has a small number of dependencies that cause problems for some users. Distributing **CollateX** in a [**docker**](https://www.docker.com/) container means that the dependences can be packaged with it. Specifically:

* **CollateX** uses the [**python-Levenshtein**](https://pypi.python.org/pypi/python-Levenshtein) package for support near matching. This package is a C library that is built on the local system, and not all users have installed the compilers the build requires.
* **CollateX** requires version 1.11 of the [**networkx**](https://pypi.python.org/pypi/networkx) library. By running **CollateX** inside a **docker** container, users who need later versions of **networkx** for other purposes will not have to create a separate environment to support the **networkx** downgrade required by **CollateX**.

## Quickstart

### Install docker

**[Add instructions, or pointer to external instructions]**

### Configure a docker image

Create the following file in an otherwise empty directory, and call it “Dockerfile”:

```bash
FROM python:3
RUN apt-get -y update
RUN apt-get -y install graphviz
RUN pip install ipython
RUN pip install collatex
RUN pip uninstall -y networkx
RUN pip install -Iv networkx==1.11
RUN pip install python-levenshtein
RUN pip install graphviz
CMD ["bash"]
```

### Create the image

Create an image by executing the following command in that directory (note that the line ends in a space followed by a dot):

```
docker build -t collatex .
```

You only have to do this once. You can then run the image with the command below without rebuilding.

### Run the image

Run the image by executing the following command:

```
docker run -i -t --rm collatex
```

The preceding steps will deposit you at the command line of a Unix virtual machine, where you will be logged in as root. You can then start an interactive python session and use **CollateX** as you normally would.

## Cleaning up

Building **docker** images may create intermediate images or containers (instances of images) that do not remove themselves cleanly when they are no longer needed. These are harmless, but messy, and they do take up disk space. The following commands will help manage them. Note that before you remove an image you need to remove any containers that refer to it.

Command | What it does 
---- | ----
`docker ps -a` | list all containers 
`docker rm <container-id>` | remove the container
`docker images -a` | list all images
`docker rmi <image-id>` | remove the image

## Explanation

Build documentation from: <https://djangostars.com/blog/what-is-docker-and-how-to-use-it-with-python/>:

* `-t` flag assigns a pseudo-tty or terminal inside the new container.
* `-i` flag allows you to make an interactive connection by grabbing the standard input (STDIN) of the container.
* `--rm` flag to automatically remove the container when the process exits. By default, containers are not deleted. This container exists until we keep the shell session and terminates when we exit from the session (like SSH session to a remote server).

----

## Notes

**[To be integrated into documentation if we launch notebook separately and need docker-compose]**
 
Alexandria uses a docker-compose.yml file, which can be used to launch multiple docker images at the same. See the example at https://github.com/Pittsburgh-NEH-Institute/Institute-Materials-2017/blob/master/schedule/week_3/alexandria.md, which launches three images, and also mounts a file-system entry point for the last of them.
