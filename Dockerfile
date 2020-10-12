FROM debian:latest

LABEL "repository"="https://github.com/Lnk2past/turtleshell"
LABEL "homepage"="https://github.com/Lnk2past/turtleshell"
LABEL "maintainer"="Lnk2past <Lnk2past@gmail.com>"

RUN echo "deb http://http.us.debian.org/debian/ testing non-free contrib main" >> /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y vim curl git make cmake gcc-10 g++-10 python3.8 python3.8-dev python3-pip \
    libjpeg-dev zlib1g-dev libssl-dev libncurses5-dev libgdbm-dev libnss3-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev

COPY requirements.txt /requirements.txt
RUN python3.8 -m pip install -r requirements.txt

RUN curl -L https://github.com/cli/cli/releases/download/v0.11.1/gh_0.11.1_linux_amd64.deb -o gh_latest.deb && \
    apt-get install ./gh_latest.deb && \
    rm -rf gh_latest.deb

RUN curl -L https://github.com/fmtlib/fmt/archive/7.0.3.tar.gz -o fmt_latest.tar.gz && \
    tar xfvz fmt_latest.tar.gz && \
    cp -R fmt-7.0.3/include/fmt /usr/include && \
    rm -rf fmt_latest.tar.gz fmt-7.0.3

RUN mkdir -p /usr/include/nlohmann && cd /usr/include/nlohmann && \
    curl -L https://github.com/nlohmann/json/releases/download/v3.9.1/json.hpp -o json.hpp

RUN curl -L https://github.com/Lnk2past/malen/archive/v2020.10.0.tar.gz -o malen_latest.tar.gz && \
    tar xfvz malen_latest.tar.gz && \
    cp -R malen-2020.10.0/include/malen /usr/include && \
    rm -rf malen_latest.tar.gz malen-2020.10.0

RUN pip install git+https://github.com/Lnk2past/malen-bokeh.git@v2020.10.0 && \
    cp -R /usr/local/include/python3.8/malen.bokeh/include/malen /usr/include/

RUN ln -s /usr/bin/python3.8 /usr/bin/python
RUN ln -s /usr/bin/python3.8-config /usr/bin/python-config
RUN ln -s /usr/lib/python3.8/config-3.8-x86_64-linux-gnu/libpython3.8.so /usr/lib/python3.8/config-3.8-x86_64-linux-gnu/libpython.so

COPY .vimrc /root/.vimrc

COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh
ENTRYPOINT ["/bin/docker-entrypoint.sh"]
