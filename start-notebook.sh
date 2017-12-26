#!/bin/bash
exec jupyter notebook --NotebookApp.token='' &> /dev/null &
exec bash
