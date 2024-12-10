package redis

import (
	"context"
	"log"
	"strconv"

	"github.com/go-redis/redis/v8"
	"gitlab.com/wit-id/test/toolkit/db"
)

func NewRedisDatabase(opt *db.RedisOption) (*redis.Client, error) {
	portString := strconv.Itoa(opt.Port)
	rdb := redis.NewClient(&redis.Options{
		Addr:     opt.Host + ":" + portString,
		Password: opt.Password,
	})

	if _, err := rdb.Ping(context.Background()).Result(); err != nil {
		log.Printf("failed connected to redis: %s, error: %s", opt.Host, err.Error())
	} else {
		log.Println("successfully connected to redis", opt.Host)
	}

	return rdb, nil
}
