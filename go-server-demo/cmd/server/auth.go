package main

import (
	"context"
	"log"
	"os"
	"strings"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/joho/godotenv"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

const googleIssuer = "https://accounts.google.com"

var (
	oauthClientID string
)

func init() {
	// load .env (only in dev; in prod your env is set differently)
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, relying on real environment")
	}
	oauthClientID = os.Getenv("GOOGLE_OAUTH_CLIENT_ID")
	if oauthClientID == "" {
		log.Fatal("GOOGLE_OAUTH_CLIENT_ID must be set")
	}
}

// authFunc validates the incoming ID Token from Google
func authFunc(ctx context.Context) (context.Context, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "missing metadata")
	}
	auth := md["authorization"]
	if len(auth) == 0 {
		return nil, status.Error(codes.Unauthenticated, "authorization token not supplied")
	}
	parts := strings.SplitN(auth[0], " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "bearer") {
		return nil, status.Error(codes.Unauthenticated, "invalid authorization format")
	}
	token := parts[1]

	// Verify the ID Token
	provider, err := oidc.NewProvider(ctx, googleIssuer)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get provider: %v", err)
	}
	verifier := provider.Verifier(&oidc.Config{ClientID: oauthClientID})

	idToken, err := verifier.Verify(ctx, token)
	if err != nil {
		return nil, status.Errorf(codes.Unauthenticated, "invalid token: %v", err)
	}

	// Optionally grab claims:
	var claims struct {
		Email string `json:"email"`
	}
	if err := idToken.Claims(&claims); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to parse claims: %v", err)
	}

	// Attach the user’s email into context for later handlers
	newCtx := context.WithValue(ctx, "userEmail", claims.Email)
	return newCtx, nil
}
