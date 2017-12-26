# Running collateX inside a docker container

David J. Birnbaum and Ronald Haentjens Dekker  
Last revised 2017-12-26

## Rationale

[**CollateX**](https://pypi.python.org/pypi/collatex) has a small number of dependencies that cause problems for some users. Distributing **CollateX** in a [**docker**](https://www.docker.com/) container means that the dependences can be packaged with it. Specifically:

* **CollateX** requires version 1.11 of the [**networkx**](https://pypi.python.org/pypi/networkx) library and the most recent release, 2.0, uses a different API, which breaks **CollateX**. By running **CollateX** inside a **docker** container, users who need later versions of **networkx** for other purposes will not have to downgrade their general Python library installation or create a separate environment to support the **networkx** version required by **CollateX**.
* **CollateX** uses the [**python-Levenshtein**](https://pypi.python.org/pypi/python-Levenshtein) package to support near matching. This package is a C library that is built on the local system, and not all users have installed the compilers the build requires.
* **CollateX** uses the [**pygraphviz**](https://pypi.python.org/pypi/pygraphviz) package to support SVG output of the variant graph. Like **python-Levenshtein**, **pygraphviz** has to be compiled on the local machine. 

## Quickstart

### Install docker

Check the “What to know before you install” section at [Docker for Mac (CE)](https://docs.docker.com/docker-for-mac/install/) or [Docker for Windows (CE)](https://docs.docker.com/docker-for-windows/install/). If you meet these requirements, install the stable channel release of **Docker CE**. If not, install [**Docker toolbox**](https://docs.docker.com/toolbox/overview/) instead.

### Configure a docker image

Create the following file in an otherwise empty directory, and call it “Dockerfile”:

```bash
FROM jupyter/datascience-notebook
USER root
RUN apt-get -y update
RUN apt-get -y install graphviz
COPY start-notebook.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start-notebook.sh
USER jovyan
RUN pip install ipython
RUN pip install collatex
RUN pip uninstall -y networkx
RUN pip install -Iv networkx==1.11
RUN pip install python-levenshtein
RUN pip install graphviz
CMD ["start-notebook.sh"]
```

Create the following file in the same directory, and call it “start-notebook.sh”

```bash
exec jupyter notebook --NotebookApp.token='' &> /dev/null &
exec bash
```

Notes

* `apt-get` and the `COPY` and `RUN` commands for **start-notebook.sh**, at the top of **Dockerfile**, must be run as root. 
* The user created by the jupyter base image has userid “jovyan”.

### Create the image

Create an image by executing the following command in that directory (note that the line ends in a space followed by a dot):

```
docker build -t collatex .
```

This may take a long time, but you only have to do it once. If the build process errors out with a “context canceled” message, run it again and it should pick up where it left off. After you’ve completed the build, you can then run the image, when needed, without rebuilding each time.

### Create a workspace

Inside the directory where you are configuring the container, run the following command

```bash
mkdir work
```

Normally information on the local file system is not accessible inside the container, and files written inside the container disappear when the container exits. We create and configure the **work** directory to hold persistent data, that is, pre-existing local files that we want to be accessible inside the container, as well as files created inside the container that we want to remain accessible on the local file system after the container exits.

### Run the image

Run the image by executing the following command:

```
 docker run -it -p 8888:8888 --rm -v /Users/djb/collatex-docker/work:/home/jovyan/work collatex
```

Notes:

* *You must change the argument to the `-v` switch* so that the part before the colon is a *full* path to a directory that exists on *your* local file system. In the section above, we created a **work** directory for that purpose, but you can mount any local directory instead. The part after the colon doesn’t change; whatever directory you have created will be accessible inside the container at the address **/home/jovyan/work**.
* If you are using port 8888 for another purpose on your host machine, change the number before the colon in the argument to the `-p` switch. For example, to access the notebook at <http://localhost:8889>, use `-p 8889:8888`.

The command above does the following:

* Deposits you at the command line of a Unix virtual machine, where you will be logged in as userid “jovyan”. You can then start an interactive python session and use **CollateX** as you normally would.
* Starts a Jupyter notebook server inside the container, which you can access from your local machine at <http://localhost:8888>. 
* Mount the local directory **/Users/djb/collatex-docker/work** inside the container as **/home/jovyan/work collatex**. Anything already in that directory when you launch the container will be accessible inside the container, and anything you write into that directory while inside the container will remain accessible on the host machine after the container exits.

## Cleaning up

Building **docker** images may create intermediate images or containers (instances of images) that do not remove themselves cleanly when they are no longer needed. These are harmless, but messy, and they do take up disk space. The following commands will help manage them. Note that before you remove an image you need to remove any containers that refer to it.

Command | What it does 
---- | ----
`docker ps -a` | list all containers 
`docker rm <container-id>` | remove the container
`docker images -a` | list all images
`docker rmi <image-id>` | remove the image

## Explanation

The strategy for starting both a notebook server and an interactive command line simultaneously is partially based on <https://stackoverflow.com/questions/34865097/run-jupyter-notebook-in-the-background-on-docker>.

The `build` command uses the following arguments (the explanation below is copied from <https://djangostars.com/blog/what-is-docker-and-how-to-use-it-with-python/>):

* `-t` flag assigns a pseudo-tty or terminal inside the new container.
* `-i` flag allows you to make an interactive connection by grabbing the standard input (STDIN) of the container.
* `--rm` flag to automatically remove the container when the process exits. By default, containers are not deleted. This container exists until we keep the shell session and terminates when we exit from the session (like SSH session to a remote server).

----

## Notes

**[To be integrated into documentation if we launch notebook separately and need docker-compose]**
 
Alexandria uses a **docker-compose.yml** file, which can be used to launch multiple docker images at the same time. See the example at <https://github.com/Pittsburgh-NEH-Institute/Institute-Materials-2017/blob/master/schedule/week_3/alexandria.md>, which launches three images, and also mounts a file-system entry point for the last of them.
