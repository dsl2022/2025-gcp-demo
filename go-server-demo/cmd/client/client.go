package main

import (
	"context"
	"log"
	"time"

	pb "github.com/dsl2022/2025-gcp-demo/go-server-demo/transfer"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	// Establish a connection (no I/O yet)
	conn, err := grpc.NewClient(
		"localhost:50051",
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		log.Fatalf("could not create client: %v", err)
	}
	defer conn.Close()

	// Create a stub and call your RPC
	client := pb.NewTransferServiceClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := client.ProcessTransfer(ctx, &pb.TransferRequest{
		TransferId:     "tx‑newclient‑001",
		FromAccount:    "ACC001",
		ToAccount:      "ACC002",
		Amount:         99.99,
		SourceCurrency: "USD",
		TargetCurrency: "EUR",
	})
	if err != nil {
		log.Fatalf("RPC error: %v", err)
	}
	log.Printf("Response: success=%v message=%q", resp.Success, resp.Message)
}
