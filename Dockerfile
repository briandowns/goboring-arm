ARG BUILD_IMAGE="armhf/ubuntu"
ARG TAG="1.14.1"

FROM debian as builder
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git gnupg wget       \
                   mercurial openssh-client subversion procps       \
                   libc6-dev make pkg-config gcc g++ openocd        \
                   gcc-arm-none-eabi binutils-arm-none-eabi    \
                   gdb-arm-none-eabi gcc-arm-linux-gnueabihf \
                   gcc-8-arm-linux-gnueabihf && \
    rm -rf /var/lib/apt/lists/*


RUN wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.14.4.linux-amd64.tar.gz        && \
    mkdir -p /go/src/go.googlesource.com /go/bin /go/pkg

ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV CC=arm-linux-gnueabihf-gcc
ENV CXX=arm-linux-gnu-g++

RUN cd /go/src/go.googlesource.com && \
    git clone https://go.googlesource.com/go
RUN cd ${GOPATH}/src/go.googlesource.com/go/src && \
    git fetch --all --tags --prune        && \
    git checkout dev.boringcrypto.go1.14  && \
    GOOS=linux GOARCH=arm ./buildall.bash

FROM ${BUILD_IMAGE}

RUN mkdir -p /go
ENV GOPATH=/go

WORKDIR /go

COPY --from=builder go/go-linux-${ARM_VERSION}-bootstrap/bin /usr/local/bin
