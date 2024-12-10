package payload

import (
	"fmt"
	"strings"
)

const (
	defaultLimit      = 10
	defaultOrderValue = "created_at DESC"
)

func limitWithDefault(limit int32) int32 {
	if limit <= 0 {
		return defaultLimit
	}

	return limit
}

func makeOffset(limit, offset int32) int32 {

	if offset == 0 {
		return (1 * limit) - limit
	} else {
		return (offset * limit) - limit
	}
}

func makeOrderParam(orderBy, sort string) string {
	if orderBy == "" || sort == "" {
		return defaultOrderValue
	}

	return fmt.Sprintf(strings.ToLower("%s %s"), orderBy, sort)
}

func queryStringLike(param string) string {
	return "%" + param + "%"
}

func translateBoolIntoNumber(param bool) int32 {
	if param {
		return 1
	} else {
		return 0
	}
}

type CommonSubResponsePayload struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}
