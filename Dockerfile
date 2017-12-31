FROM jupyter/datascience-notebook
USER root
COPY start-notebook.sh '/usr/local/bin'
RUN apt-get -y update && apt-get install -y \
    graphviz \
    libgraphviz-dev \
    graphviz-dev \
    pkg-config \
    tofrodos \
  && rm -rf /var/lib/apt/lists/* \
  && fromdos '/usr/local/bin/start-notebook.sh' \
  && chmod +x '/usr/local/bin/start-notebook.sh'
USER jovyan
RUN pip install --upgrade --pre collatex \
  && pip install python-levenshtein \
  && pip install pygraphviz
CMD ["start-notebook.sh"]
