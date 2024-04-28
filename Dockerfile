
FROM debian:stable-20240423-slim as base_builder

RUN apt update && apt upgrade -y curl git

FROM base_builder as conda_builder

COPY environment.yml /root/environment.yml
ADD .bashrc_conda /root/.bashrc_conda
RUN  cat /root/.bashrc_conda >> ~/.bashrc
SHELL ["/bin/bash", "-c"]

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x Miniconda3-latest-Linux-x86_64.sh \
    && ./Miniconda3-latest-Linux-x86_64.sh -b \
    && source /root/.bashrc && conda install mamba -n base -c conda-forge -y \
    && mamba env update --name base --file /root/environment.yml --prune \
    && conda clean -afy

FROM base_builder as dep_builder

RUN curl -L https://github.com/fmtlib/fmt/archive/refs/tags/10.2.1.tar.gz -o fmt_latest.tar.gz && \
    tar xfvz fmt_latest.tar.gz && \
    cp -R fmt-10.2.1/include/fmt /usr/include && \
    rm -rf fmt_latest.tar.gz fmt-10.2.1

RUN mkdir -p /usr/include/nlohmann \
    && curl -L https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp -o /usr/include/nlohmann/json.hpp

RUN curl -L https://github.com/pybind/pybind11/archive/refs/tags/v2.12.0.tar.gz -o pybind11_latest.tar.gz && \
    tar xfvz pybind11_latest.tar.gz && \
    cp -R pybind11-2.12.0/include/pybind11 /usr/include && \
    rm -rf pybind11_latest.tar.gz pybind11-2.12.0

RUN curl -L https://github.com/pybind/pybind11_json/archive/refs/tags/0.2.13.tar.gz -o pybind11_json_latest.tar.gz && \
    tar xfvz pybind11_json_latest.tar.gz && \
    cp -R pybind11_json-0.2.13/include/pybind11_json /usr/include && \
    rm -rf pybind11_json_latest.tar.gz pybind11_json-0.2.13

FROM debian:stable-20240423-slim

LABEL "repository"="https://github.com/Lnk2past/turtleshell"
LABEL "homepage"="https://github.com/Lnk2past/turtleshell"
LABEL "maintainer"="Lnk2past <Lnk2past@gmail.com>"

RUN apt update && apt upgrade -y \
    && apt install -y \
        vim curl git make cmake gcc-12 g++-12 \
        libunwind-dev google-perftools valgrind libjpeg-dev zlib1g-dev libssl-dev \
        libncurses5-dev libgdbm-dev libnss3-dev libreadline-dev libffi-dev \
        libbz2-dev \
     && apt-get clean -y

COPY --from=conda_builder /root/.bashrc /root/.bashrc_conda /root/
COPY --from=conda_builder /root/miniconda3/ /root/miniconda3/
COPY --from=dep_builder /usr/include/fmt /usr/include/fmt
COPY --from=dep_builder /usr/include/nlohmann /usr/include/nlohmann
COPY --from=dep_builder /usr/include/pybind11 /usr/include/pybind11
COPY --from=dep_builder /usr/include/pybind11_json /usr/include/pybind11_json

COPY .vimrc /root/.vimrc

RUN ln -s /usr/bin/g++-12 /usr/bin/g++

WORKDIR /root/home/turtleshell
