FROM golang:1.22.0 as build

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ENV CGO_ENABLED=0

RUN VERSION=$(git describe --tags --always) \
    ARCH=$(go env GOARCH) \
    SUFFIX="-${ARCH}" \
    LINKFLAGS="-X github.com/rancher/csp-adapter.Version=$VERSION" && \
    go build -ldflags "$LINKFLAGS -extldflags -static -s" -o bin/csp-adapter

FROM registry.suse.com/bci/bci-micro:15.6 as final

ARG user=adapter

RUN echo "$user:x:1000:1000::/home/$user:/bin/bash" >> /etc/passwd && \
    echo "$user:x:1000:" >> /etc/group && \
    mkdir /home/$user && \
    chown -R $user:$user /home/$user

COPY --from=build /app/bin/csp-adapter /usr/bin/

USER $user

CMD ["csp-adapter"]
