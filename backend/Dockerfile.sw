# Build arguments
ARG SOURCE_CODE=.


# Use ubi8/nodejs-14 as base image
FROM registry.redhat.io/ubi8/go-toolset:1.21@sha256:742ae6ec1aef3e7faae488c47695fb64964d342aefecf52d23bd9d5e6731d0b6 as builder


## Build args to be used at this step
ARG SOURCE_CODE

## Switch to root as required for some operations
USER root

COPY ${SOURCE_CODE}/go.mod ./
COPY ${SOURCE_CODE}/go.sum ./


# Copy the source
COPY ${SOURCE_CODE}/ ./

RUN GO111MODULE=on go build -o /bin/controller backend/src/crd/controller/scheduledworkflow/*.go

FROM registry.redhat.io/ubi8/ubi-minimal@sha256:c12e67af6a7e15113d76bc72f10bef2045c026c71ec8b7124c8a075458188a83
WORKDIR /bin

COPY --from=builder /bin/controller /bin/controller
RUN chmod +x /bin/controller

RUN microdnf makecache && \
     microdnf install -y tzdata.noarch

ENV NAMESPACE ""

CMD /bin/controller --logtostderr=true --namespace=${NAMESPACE}


