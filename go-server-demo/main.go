package main

import (
	"context"
	"log"
	"net"

	"cloud.google.com/go/pubsub"
	pb "github.com/dsl2022/2025-gcp-demo/go-server-demo/transfer"
	"google.golang.org/grpc"
)

const (
	grpcPort = ":50051"
	// add projectID to env
	projectID = "gcp-demo-460104"
	topicID   = "audit-events"
)

func main() {
	ctx := context.Background()
	pubsubClient, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("pubsub.NewClient: %v", err)
	}
	topic := pubsubClient.Topic(topicID)
	defer topic.Stop()
	lis, err := net.Listen("tcp", grpcPort)
	if err != nil {
		log.Fatalf("net.Listen: %v", err)
	}
	grpcServer := grpc.NewServer()
	pb.RegisterTransferServiceServer(grpcServer, &server{pubTopic: topic})

	log.Printf("gRPC server listening on %s", grpcPort)
	log.Fatal(grpcServer.Serve(lis))
}
