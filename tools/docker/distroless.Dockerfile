FROM golang:1.15-alpine AS builder

# Go flags
# CGO_ENABLED=0 will disable dynamic link and forcing go build
# to do a static compilation of the C libraries
ENV GOOS=linux \
    GOARCH=amd64 \
    GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build

# Let's cache modules retrieval - those don't change so often
COPY go.mod .
COPY go.sum .

RUN go mod download

# Copy the code necessary to build the application
# You may want to change this to copy only what you actually need.
COPY . .

# Build the application
# RUN go build -tags=jsoniter ./
RUN go build -a -tags=jsoniter -ldflags="-w -s" -o ./app

# Let's create a /dist folder containing just the files necessary for runtime.
# Later, it will be copied as the / (root) of the output image.
WORKDIR /dist
RUN cp /build/app ./app

# Copy or create other directories/files your app needs during runtime.
# E.g. this example uses /data as a working directory that would probably
#      be bound to a perstistent dir when running the container normally
RUN mkdir /data

################################################################################

# Since distroless does not have a COPY command,
# We use docker to copy a timezone file from self image (different container)
# to itself
FROM gcr.io/distroless/base AS timezone

################################################################################

# Create the minimal runtime image
FROM gcr.io/distroless/base

# Distroless does not have the ability to do so...
# Change timezone to be Asia/Bangkok
COPY --chown=0:0 --from=timezone /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

# Copy over the binary file
COPY --chown=0:0 --from=builder /dist /

# Set up the app to run as a non-root user inside the /data folder
# User ID 65534 is usually user 'nobody'.
# The executor of this image should still specify a user during setup.
COPY --chown=65534:0 --from=builder /data /data

USER 65534
ENTRYPOINT ["/app"]
