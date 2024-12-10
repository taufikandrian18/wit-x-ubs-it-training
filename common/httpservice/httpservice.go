package httpservice

import (
	"context"
	"database/sql"

	"cloud.google.com/go/storage"
	"gitlab.com/wit-id/test/toolkit/config"
)

type Service struct {
	mainDB           *sql.DB
	connectionString string
	//redisClient   *redis.Client
	cfg           config.KVStore
	storageClient *storage.BucketHandle
}

func NewService(
	mainDB *sql.DB,
	connectionString string,
	//redisClient *redis.Client,
	cfg config.KVStore,
	storageClient *storage.BucketHandle,
) *Service {
	return &Service{
		mainDB:           mainDB,
		connectionString: connectionString,
		//redisClient:   redisClient,
		cfg:           cfg,
		storageClient: storageClient,
	}
}

func (s *Service) GetDB() *sql.DB {
	return s.mainDB
}

func (s *Service) GetConnectionString() string {
	return s.connectionString
}

func (s *Service) GetStorageClient() *storage.BucketHandle {
	return s.storageClient
}

func (s *Service) GetServiceHealth(_ context.Context) error {
	// do health check logic here
	return nil
}
