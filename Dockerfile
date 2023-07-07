# https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html
# 2023-05-30 22.04 3.10 4d70cf8da953
#FROM jupyter/scipy-notebook:bbf0ada0a935
FROM jupyter/scipy-notebook:4d70cf8da953

USER root
WORKDIR /tmp

RUN apt-get update && \
 apt-get install -yq --no-install-recommends curl && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

#COPY . vectorbt
COPY vectorbt vectorbt
COPy setup.py vectorbt/setup.py
WORKDIR vectorbt
RUN chmod -R +x scripts

ARG FULL="yes"
RUN pip install --upgrade pip
RUN if [[ -n "${FULL}" ]] ; then \
    curl -O https://netcologne.dl.sourceforge.net/project/ta-lib/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz && \
    tar -xzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib/ && \
    ./configure --prefix=/usr && \
    make && \
    sudo make install && \
    cd .. && \
    rm -rf ta-lib && \
    rm ta-lib-0.4.0-src.tar.gz && \
    pip install --no-cache-dir .[full] ; else \
    pip install --no-cache-dir . ; fi

RUN pip install \
      python-telegram-bot==13.15 \
    pip install -U \
      kaleido \
      jinja2

RUN scripts/install-labextensions.sh && \
    jupyter lab clean && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging

USER $NB_UID

ARG TEST

RUN if [[ -n "${TEST}" ]] ; then \
    pip install --no-cache-dir pytest && \
    export NUMBA_BOUNDSCHECK=1 && \
    export NUMBA_DISABLE_JIT=1 && \
    python -m pytest -p no:cacheprovider -k 'not test_value_counts' tests ; fi

WORKDIR "$HOME/work"

ENV JUPYTER_ENABLE_LAB "yes"
