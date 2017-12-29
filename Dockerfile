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
# Temporary fix because pip installs 2.1.2 instead of current 2.1.3rc
RUN pip install --upgrade --pre collatex \
  && pip uninstall -y networkx \
  && pip install -Iv networkx==1.11 \
  && pip install python-levenshtein \
  && pip install pygraphviz
CMD ["start-notebook.sh"]
