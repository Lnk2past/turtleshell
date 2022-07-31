FROM debian:latest

LABEL "repository"="https://github.com/Lnk2past/turtleshell"
LABEL "homepage"="https://github.com/Lnk2past/turtleshell"
LABEL "maintainer"="Lnk2past <Lnk2past@gmail.com>"

RUN apt update && apt upgrade -y \
    && apt install -y \
        vim curl git make cmake gcc-10 g++-10 \
        libunwind-dev google-perftools valgrind libjpeg-dev zlib1g-dev libssl-dev \
        libncurses5-dev libgdbm-dev libnss3-dev libreadline-dev libffi-dev \
        libbz2-dev \
     && apt-get clean -y

ADD .bashrc_conda /root/.bashrc_conda
RUN  cat /root/.bashrc_conda >> ~/.bashrc
SHELL ["/bin/bash", "-c"] 

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x Miniconda3-latest-Linux-x86_64.sh \
    && ./Miniconda3-latest-Linux-x86_64.sh -b \
    && source /root/.bashrc && conda install mamba -n base -c conda-forge -y

COPY environment.yml /root/environment.yml
RUN source /root/.bashrc && mamba env update --name base --file /root/environment.yml --prune

RUN curl -L https://github.com/cli/cli/releases/download/v2.14.3/gh_2.14.3_linux_amd64.deb -o gh_latest.deb && \
    apt install ./gh_latest.deb && \
    rm -rf gh_latest.deb

RUN curl -L https://github.com/fmtlib/fmt/archive/9.0.0.tar.gz -o fmt_latest.tar.gz && \
    tar xfvz fmt_latest.tar.gz && \
    cp -R fmt-9.0.0/include/fmt /usr/include && \
    rm -rf fmt_latest.tar.gz fmt-9.0.0

RUN mkdir -p /usr/include/nlohmann \
    && curl -L https://github.com/nlohmann/json/releases/download/v3.10.5/json.hpp -o /usr/include/nlohmann/json.hpp

COPY .vimrc /root/.vimrc

RUN ln -s /usr/bin/g++-10 /usr/bin/g++

WORKDIR /root/home/turtleshell
