# Stage 1: Builder
FROM golang:1.24-alpine AS builder
WORKDIR /src

# Download deps
COPY go.mod ./
RUN go mod download

# Copy source and compile for Linux AMD64, static binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o /app/server main.go

# Stage 2: Runtime
FROM alpine:3.21
RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /app/server .

EXPOSE 8080
CMD ["./server"]
