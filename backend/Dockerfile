# Build arguments
ARG SOURCE_CODE=.

FROM registry.access.redhat.com/ubi8/go-toolset:1.21 as builder

## Build args to be used at this step
ARG SOURCE_CODE

USER root

# Needed musl-dev for github.com/mattn/go-sqlite3
RUN dnf update -y && \
    dnf install -y cmake clang openssl --skip-broken

COPY ${SOURCE_CODE}/go.mod ./
COPY ${SOURCE_CODE}/go.sum ./

# Copy the source
COPY ${SOURCE_CODE}/ ./

RUN GO111MODULE=on go build -o /bin/apiserver ./backend/src/apiserver/ && \
    dnf clean all

FROM registry.redhat.io/ubi8/ubi-minimal:latest

WORKDIR /bin

COPY --from=builder /opt/app-root/src/backend/src/apiserver/config/ /config
COPY --from=builder /bin/apiserver /bin/apiserver

RUN chmod +x /bin/apiserver

USER root

Adding CA certificate so API server can download pipeline through URL and wget is used for liveness/readiness probe command
RUN microdnf update -y && \
    microdnf install -y ca-certificates wget

USER 1001

# Expose apiserver port
EXPOSE 8888

# Start the apiserver
CMD /bin/apiserver --config=/config --sampleconfig=/config/sample_config.json -logtostderr=true

LABEL name="ds-pipelines-api-server" \
      summary="DSP Server"
