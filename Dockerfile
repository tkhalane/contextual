# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-mygolangproject"
LABEL REPO="https://github.com/lacion/mygolangproject"

ENV PROJPATH=/go/src/github.com/lacion/mygolangproject

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/lacion/mygolangproject
WORKDIR /go/src/github.com/lacion/mygolangproject

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/lacion/mygolangproject"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/mygolangproject/bin

WORKDIR /opt/mygolangproject/bin

COPY --from=build-stage /go/src/github.com/lacion/mygolangproject/bin/mygolangproject /opt/mygolangproject/bin/
RUN chmod +x /opt/mygolangproject/bin/mygolangproject

# Create appuser
RUN adduser -D -g '' mygolangproject
USER mygolangproject

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/mygolangproject/bin/mygolangproject"]
