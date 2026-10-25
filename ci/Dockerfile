FROM ubuntu:24.04
WORKDIR /app
# ===== Go 模块加速 =====
ENV GOPROXY=https://goproxy.cn,direct \
    GOSUMDB=sum.golang.google.cn \
    GO111MODULE=on

# ===== pip 加速 =====
ENV PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    PIP_DEFAULT_TIMEOUT=600 \
    PIP_RETRIES=10
    
RUN apt-get update
RUN apt-get install -y \
        ca-certificates \
        cargo \
        cmake \
        git \
        golang-go \
        intltool \
        libarchive-dev \
        libcurl4-openssl-dev \
        libevent-dev \
        libffi-dev \
        libfuse-dev \
        libglib2.0-dev \
        libjansson-dev \
        libjpeg-dev \
        libjwt-dev \
        libldap2-dev \
        libmariadbclient-dev-compat \
        libonig-dev \
        libpq-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        uuid-dev \
        valac \
        wget \
        curl \
        libunwind-dev \
        libhiredis-dev \
        google-perftools \
        libgoogle-perftools-dev \
        libargon2-dev
RUN apt-get install -y \
        python3 \
        python3-distro \
        python3-lxml \
        python3-ldap \
        python3-pip \
        python3-setuptools \
        python3-wheel 
RUN apt-get clean
COPY .. .

