package query

import (
	"encoding/json"

	"gitlab.com/wit-id/test/common/httpservice"
)

type DBError struct {
	Error *struct {
		Code    string `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func (d *DBError) Unmarshal(raw []byte) (isExists bool, err error) {
	err = json.Unmarshal(raw, &d)
	if err != nil {
		return false, httpservice.ErrInternalServerError
	}
	if d.Error != nil {
		return true, nil
	}
	return false, nil
}
