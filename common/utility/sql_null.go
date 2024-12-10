package utility

import (
	"database/sql"
	"strconv"
)

func NullIntToString(in sql.NullInt32) string {
	if in.Valid {
		return strconv.Itoa(int(in.Int32))
	} else {
		return "NULL"
	}
}
