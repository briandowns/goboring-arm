ARG BUILD_IMAGE="armhf/ubuntu"
ARG TAG="1.14.1"

FROM ${BUILD_IMAGE} as builder
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git gnupg dirmgr           \
                   mercurial openssh-client subversion procps \
                   libc6-dev make pkg-config g++ gcc       && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://go.googlesource.com/go
RUN git fetch --all --tags --prune && \
    git checkout tags/${TAG} -b ${TAG}  
RUN cd go/src && \
    CGO_ENABLED=1 GOOS=linux GOARCH=${ARM_VERSION} ./buildall.bash

FROM scratch

RUN mkdir -p /go
ENV GOPATH=/go

WORKDIR /go

COPY --from=builder go/go-linux-${ARM_VERSION}-bootstrap/bin /usr/local/bin
