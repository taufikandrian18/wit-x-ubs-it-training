package storage

import (
	"fmt"
	"log"

	"cloud.google.com/go/storage"
	"gitlab.com/wit-id/test/toolkit/config"
)

func NewFromConfig(cfg config.KVStore, path string) (*storage.BucketHandle, error) {
	gcsOpt, err := NewGoogleCloudStorageOption(
		cfg.GetString(fmt.Sprintf("%s.google-cloud-storage.service-account-path", path)),
		cfg.GetString(fmt.Sprintf("%s.google-cloud-storage.bucket-name", path)),
	)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	opt, err := NewStorageOption(
		gcsOpt,
	)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return NewStorageClient(opt)
}

type GoogleCloudStorageOption struct {
	ServiceAccountPath string
	BucketName         string
	BaseUrl            string
}

type Option struct {
	*GoogleCloudStorageOption
}

func NewGoogleCloudStorageOption(
	serviceAccountPath, bucketName string) (
	*GoogleCloudStorageOption, error) {
	return &GoogleCloudStorageOption{
		ServiceAccountPath: serviceAccountPath,
		BucketName:         bucketName,
	}, nil
}

func NewStorageOption(gscOpt *GoogleCloudStorageOption) (*Option, error) {
	return &Option{
		GoogleCloudStorageOption: gscOpt,
	}, nil
}
