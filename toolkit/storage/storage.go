package storage

import (
	"context"
	"io/ioutil"
	"log"
	"os"

	"cloud.google.com/go/storage"
	"google.golang.org/api/option"
)

func NewStorageClient(opt *Option) (*storage.BucketHandle, error) {

	jsonFile, err := os.Open(opt.GoogleCloudStorageOption.ServiceAccountPath)
	// if we os.Open returns an error then handle it
	if err != nil {
		log.Println(err)
		return nil, err
	}
	// defer the closing of our jsonFile so that we can parse it later on
	defer jsonFile.Close()

	byteValue, _ := ioutil.ReadAll(jsonFile)

	clientOption := []option.ClientOption{
		option.WithCredentialsJSON(byteValue),
	}

	storageClient, err := storage.NewClient(context.Background(), clientOption...)
	if err != nil {
		log.Print(err)
		return nil, err
	}
	defer storageClient.Close()

	log.Println(storageClient.Buckets(context.Background(), "artotel"))

	return storageClient.Bucket(opt.BucketName), nil
}
