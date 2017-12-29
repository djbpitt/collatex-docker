FROM jupyter/datascience-notebook
USER root
RUN apt-get -y update
RUN apt-get -y install graphviz libgraphviz-dev graphviz-dev pkg-config
RUN apt-get install tofrodos
COPY start-notebook.sh '/usr/local/bin'
RUN fromdos '/usr/local/bin/start-notebook.sh'
RUN chmod +x '/usr/local/bin/start-notebook.sh'
USER jovyan
RUN pip install ipython
# Temporary fix because pip installs 2.1.2 instead of current 2.1.3rc
RUN pip install -I collatex==2.1.3rc
RUN pip uninstall -y networkx
RUN pip install -Iv networkx==1.11
RUN pip install python-levenshtein
RUN pip install pygraphviz
CMD ["start-notebook.sh"]
