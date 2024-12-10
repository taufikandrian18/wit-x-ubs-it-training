package main

import (
	"time"

	"github.com/pkg/errors"
	"github.com/spf13/viper"
	"gitlab.com/wit-id/test/common/echohttp"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/db/oracle"
	"gitlab.com/wit-id/test/toolkit/log"
	"gitlab.com/wit-id/test/toolkit/runtimekit"
	_ "go.elastic.co/apm/module/apmsql/pq"
)

func main() {
	var err error

	setDefaultTimezone()

	appContext, cancel := runtimekit.NewRuntimeContext()
	defer func() {
		cancel()

		if err != nil {
			log.FromCtx(appContext).Error(err, "found error")
		}
	}()

	// Set config file (env)
	appConfig, err := envConfigVariable("config.yaml")
	if err != nil {
		return
	}

	// setup db
	mainDB, connectionString, err := oracle.NewFromConfig(appConfig, "db")
	if err != nil {
		return
	}

	// setup logging
	logger, err := log.NewFromConfig(appConfig, "log")
	if err != nil {
		return
	}

	logger.Set()

	// setup service
	svc := httpservice.NewService(mainDB, connectionString, appConfig, nil)
	// expose echo http server
	echohttp.RunEchoHTTPService(appContext, svc, appConfig)
}

func setDefaultTimezone() {
	loc, err := time.LoadLocation("UTC")
	if err != nil {
		loc = time.Now().Location()
	}

	time.Local = loc
}

func envConfigVariable(filePath string) (cfg *viper.Viper, err error) {
	cfg = viper.New()
	cfg.SetConfigFile(filePath)

	if err = cfg.ReadInConfig(); err != nil {
		err = errors.Wrap(err, "Error while reading config file")

		return
	}

	return
}
