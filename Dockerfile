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
