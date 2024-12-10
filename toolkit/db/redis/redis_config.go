package redis

import (
	"fmt"

	"github.com/go-redis/redis/v8"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/db"
)

func NewFromConfig(cfg config.KVStore, path string) (*redis.Client, error) {
	opt, err := db.NewRedisOption(
		cfg.GetString(fmt.Sprintf("%s.host", path)),
		cfg.GetInt(fmt.Sprintf("%s.port", path)),
		cfg.GetString(fmt.Sprintf("%s.password", path)),
	)
	if err != nil {
		return nil, err
	}

	return NewRedisDatabase(opt)
}
