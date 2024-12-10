package oracle

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/url"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/godror/godror"

	"gitlab.com/wit-id/test/toolkit/db"
)

// NewPostgresDatabase - create & validate postgres connection given certain db.Option
// the caller have the responsibility to close the *sqlx.DB when succeed.
func NewOracleDatabase(opt *db.Option) (*sql.DB, string, error) {
	connURL := &url.URL{
		Scheme: "UBS_TRAINING",
		User:   url.UserPassword(opt.Username, opt.Password),
		Host:   fmt.Sprintf("%s:%d", opt.Host, opt.Port),
		Path:   opt.DatabaseName,
	}
	q := connURL.Query()
	q.Add("sslmode", "disable")
	connURL.RawQuery = q.Encode()

	var P godror.ConnectionParams
	P.Username, P.Password = opt.Username, godror.NewPassword(opt.Password)
	P.ConnectString = opt.Host + `:` + fmt.Sprintf("%v", opt.Port) + "/" + opt.DatabaseName + "?connect_timeout=2"
	P.SessionTimeout = 42 * time.Second
	P.SetSessionParamOnInit("NLS_NUMERIC_CHARACTERS", ",.")
	P.SetSessionParamOnInit("NLS_LANGUAGE", "FRENCH")

	db := sql.OpenDB(godror.NewConnector(P))
	connectionString := opt.Username + "/" + opt.Password + "@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(Host=" + opt.Host + ")(Port=" + fmt.Sprintf("%v", opt.Port) + ")))(CONNECT_DATA=(SID=" + opt.DatabaseName + ")))"

	db.SetMaxIdleConns(opt.ConnectionOption.MaxIdle)
	db.SetConnMaxLifetime(opt.ConnectionOption.MaxLifetime)
	db.SetMaxOpenConns(opt.ConnectionOption.MaxOpen)

	ctx, cancel := context.WithTimeout(context.Background(), opt.ConnectionOption.ConnectTimeout)
	defer cancel()

	res := db.QueryRowContext(ctx, "SELECT 1 FROM DUAL")
	if res.Err() != nil {
		fmt.Println("error connecting to db Err=", res.Err())
		panic(res.Err())
	}

	log.Println("successfully connected to oracle", connURL.Host)

	go doKeepAliveConnection(db)

	return db, connectionString, nil
}

func NewFakePostgresDB() (*sql.DB, error) {
	db, _, err := sqlmock.New()
	if err != nil {
		return nil, err
	}
	defer db.Close()

	return db, nil
}

func doKeepAliveConnection(db *sql.DB) {
	// Periodically execute a simple statement
	ticker := time.NewTicker(10 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			_, err := db.Exec("SELECT 1 FROM DUAL")
			if err != nil {
				log.Println("Error executing statement:", err)
			}
		}
	}
}
