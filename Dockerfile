ARG BUILD_IMAGE="armhf/ubuntu"

FROM debian as builder
ENV LC_ALL C

RUN apt update                                 && \ 
    apt upgrade -y                             && \ 
    apt install -y ca-certificates git gnupg wget \
    build-essential make gcc jq

# install Go and create Go path directories
ARG TAG="1.14.4"
RUN wget https://golang.org/dl/go${TAG}.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go${TAG}.linux-arm64.tar.gz     && \
    mkdir -p /go/src/go.googlesource.com /go/bin /go/pkg

# build Go w/GoBoring (boringSSL)
ENV PATH="${PATH}:/usr/local/go/bin"
RUN wget https://go-boringcrypto.storage.googleapis.com/go${TAG}b4.src.tar.gz && \
    tar -xvf go${TAG}b4.src.tar.gz                                            && \
    cd go/src                                                                 && \
    CGO_ENABLED=1 GOOS=linux GOARCH=arm64 ./all.bash 

FROM ${BUILD_IMAGE}
ENV LC_ALL C

RUN apt update     && \
    apt upgrade -y && \
    apt install -y ca-certificates wget

ARG TRIVY_VERSION=0.7.0
RUN wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz && \
    tar -zxvf trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz                                                                      && \
    mv trivy /usr/local/bin                                                                                                  && \
    trivy --download-db-only    

RUN mkdir -p /go

ENV GOPATH=/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p "${GOPATH}/src"

WORKDIR /go

COPY --from=builder /go/bin /usr/local/bin

