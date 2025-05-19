# Stage 1: Builder
FROM golang:1.24-alpine AS builder
WORKDIR /src

# Download deps
COPY go.mod go.sum ./
RUN go mod download

# Copy everything (including the generated transfer/ folder)
COPY . .

# Build the server binary from cmd/server
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o /app/server ./cmd/server

# Stage 2: Runtime
FROM alpine:3.21
RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /app/server .

# gRPC defaults to port 50051
EXPOSE 50051

CMD ["./server"]
