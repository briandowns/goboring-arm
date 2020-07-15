ARG BUILD_IMAGE="armhf/ubuntu"

FROM debian as builder
RUN apt update                                 && \ 
    apt upgrade -y                             && \ 
    apt install -y ca-certificates git gnupg wget \
    build-essential make gcc

# install Go and create Go path directories
ARG GO_VERSION="1.14.4"
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz     && \
    mkdir -p /go/src/go.googlesource.com /go/bin /go/pkg

# build Go w/GoBoring (boringSSL)
ENV PATH="${PATH}:/usr/local/go/bin"
RUN wget https://go-boringcrypto.storage.googleapis.com/go${GO_VERSION}b4.src.tar.gz && \
    tar -xvf go${GO_VERSION}b4.src.tar.gz                                            && \
    cd go/src                                                                        && \
    ./all.bash 

FROM ${BUILD_IMAGE}

RUN mkdir -p /go
ENV GOPATH=/go

WORKDIR /go

COPY --from=builder /go/bin /usr/local/bin

