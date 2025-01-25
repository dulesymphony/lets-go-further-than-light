# Use an official Golang runtime as a parent image
FROM golang:1.22 as builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app. Note that we're now specifying the path to main.go
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o lets-go-further-than-light ./cmd/api/main.go

# Use a minimal alpine image
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from the builder stage
COPY --from=builder /app/lets-go-further-than-light .

# Run the binary program produced by `go build`
CMD ["./lets-go-further-than-light"]