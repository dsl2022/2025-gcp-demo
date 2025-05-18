package main

import (
	"context"
	"encoding/json"
	"log"

	"cloud.google.com/go/pubsub"
	pb "github.com/dsl2022/2025-gcp-demo/go-server-demo/transfer"
)

type server struct {
	pb.UnimplementedTransferServiceServer
	pubTopic *pubsub.Topic
}

func (s *server) ProcessTransfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	// Simulate crypto conversion concurrently
	resultCh := make(chan error, 1)
	go func() {
		log.Printf("Converting %.2f %s → %s (transfer %s)",
			req.Amount, req.SourceCurrency, req.TargetCurrency, req.TransferId)
		// TODO: real exchange API call
		resultCh <- nil
	}()
	if err := <-resultCh; err != nil {
		return &pb.TransferResponse{
			TransferId: req.TransferId, Success: false, Message: "Conversion failed",
		}, nil
	}

	// Simulate ledger update
	log.Printf("Ledger updated for transfer %s", req.TransferId)
	evt := map[string]interface{}{
		"transfer_id":     req.TransferId,
		"from_account":    req.FromAccount,
		"to_account":      req.ToAccount,
		"amount":          req.Amount,
		"source_currency": req.SourceCurrency,
		"target_currency": req.TargetCurrency,
		"status":          "COMPLETED",
	}
	data, _ := json.Marshal(evt)
	res := s.pubTopic.Publish(ctx, &pubsub.Message{Data: data})
	if msgID, err := res.Get(ctx); err != nil {
		log.Printf("failed to publish audit event: %v", err)
	} else {
		log.Printf("published audit event with ID: %s", msgID)
	}
	return &pb.TransferResponse{
		TransferId: req.TransferId, Success: true, Message: "Transfer completed",
	}, nil
}
