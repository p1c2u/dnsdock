FROM alpine:3.6 AS builder

ARG GOLANG_VERSION=1.8.4-r0

RUN apk update
RUN apk add go=${GOLANG_VERSION} go-tools=${GOLANG_VERSION} git musl-dev
RUN go version

ENV GOPATH=/go
ENV PATH=${PATH}:/go/bin
ENV CGO_ENABLED=0

RUN go get -v github.com/tools/godep
# RUN go get -u github.com/golang/lint/golint
RUN go get github.com/ahmetb/govvv

RUN mkdir -p /go/src/github.com/p1c2u/dnsdock

WORKDIR /go/src/github.com/p1c2u/dnsdock

RUN git clone https://github.com/p1c2u/dnsdock /go/src/github.com/p1c2u/dnsdock 
# RUN git checkout {{$GIT_COMMIT}}

RUN mkdir /tmp/output

WORKDIR /go/src/github.com/p1c2u/dnsdock

ENV GIT_SSL_NO_VERIFY=true

RUN godep restore

ENV GOARCH=arm64

WORKDIR /go/src/github.com/p1c2u/dnsdock/src

RUN govvv build -o /tmp/output/dnsdock

FROM alpine:3.18.2

COPY --from=builder /tmp/output/dnsdock /bin/dnsdock

ENTRYPOINT ["dnsdock"]
