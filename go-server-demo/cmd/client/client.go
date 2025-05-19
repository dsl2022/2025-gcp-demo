package main

import (
	"context"
	"flag"
	"log"
	"os"
	"time"

	pb "github.com/dsl2022/2025-gcp-demo/go-server-demo/transfer"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	// 1) Parse the server address from --addr or SERVER_ADDR
	addr := flag.String("addr", "", "gRPC server address (host:port)")
	flag.Parse()

	if *addr == "" {
		*addr = os.Getenv("SERVER_ADDR")
	}
	if *addr == "" {
		log.Fatal("must specify server address with --addr or SERVER_ADDR")
	}

	// 2) Establish a connection (no I/O yet)
	conn, err := grpc.NewClient(
		*addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		log.Fatalf("could not create client: %v", err)
	}
	defer conn.Close()

	// 3) Create a stub and call your RPC
	client := pb.NewTransferServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := client.ProcessTransfer(ctx, &pb.TransferRequest{
		TransferId:     "live-test-001",
		FromAccount:    "ACC001",
		ToAccount:      "ACC002",
		Amount:         42.00,
		SourceCurrency: "USD",
		TargetCurrency: "EUR",
	})
	if err != nil {
		log.Fatalf("RPC error: %v", err)
	}
	log.Printf("Response: success=%v message=%q", resp.Success, resp.Message)
}
