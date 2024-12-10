package payload

import (
	"context"
	"database/sql"

	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
)

type CreateMasterdataPayload struct {
	Category string  `json:"category" valid:"required~category is required field"`
	Value1   string  `json:"value_1" valid:"required~value_1 is required field"`
	Value2   *string `json:"value_2"`
	ParentID *int64  `json:"parent_id"`
}

func (payload *CreateMasterdataPayload) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return nil
}

func (payload *CreateMasterdataPayload) ToEntity(guid string) (data query.InsertMasterDataParams) {
	var Value2 sql.NullString
	var ParentID sql.NullInt64

	if payload.Value2 != nil {
		if *payload.Value2 != "" {
			Value2 = sql.NullString{
				String: *payload.Value2,
				Valid:  true,
			}
		}
	}
	if payload.ParentID != nil {
		if *payload.ParentID != 0 {
			ParentID = sql.NullInt64{
				Int64: *payload.ParentID,
				Valid: true,
			}
		}
	}

	data = query.InsertMasterDataParams{
		Category:  payload.Category,
		Value1:    payload.Value1,
		Value2:    Value2,
		ParentID:  ParentID,
		CreatedBy: guid,
	}

	return
}

type UpdateMasterdataPayload struct {
	OrderNumber int64   `json:"order_number"`
	Category    string  `json:"category" valid:"required~category is required field"`
	Value1      string  `json:"value_1" valid:"required~value_1 is required field"`
	Value2      *string `json:"value_2"`
	ParentID    *int64  `json:"parent_id"`
}

func (payload *UpdateMasterdataPayload) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return nil
}

func (payload *UpdateMasterdataPayload) ToEntity(guid, updatedBy string) (data query.UpdateMasterdataParams) {
	var Value2 sql.NullString
	var ParentID sql.NullInt64

	if payload.Value2 != nil {
		if *payload.Value2 != "" {
			Value2 = sql.NullString{
				String: *payload.Value2,
				Valid:  true,
			}
		}
	}
	if payload.ParentID != nil {
		if *payload.ParentID != 0 {
			ParentID = sql.NullInt64{
				Int64: *payload.ParentID,
				Valid: true,
			}
		}
	}

	data = query.UpdateMasterdataParams{
		GUID:        guid,
		OrderNumber: payload.OrderNumber,
		Category:    payload.Category,
		Value1:      payload.Value1,
		Value2:      Value2,
		ParentID:    ParentID,
		UpdatedBy:   updatedBy,
	}

	return
}

type ListFilterMasterdataPayload struct {
	SetCategory bool    `json:"set_category"`
	Category    string  `json:"category"`
	SetValue1   bool    `json:"set_value1"`
	Value1      string  `json:"value1"`
	SetValue2   bool    `json:"set_value2"`
	Value2      *string `json:"value2"`
	SetParentID bool    `json:"set_parent_id"`
	ParentID    *int64  `json:"parent_id"`
}

type ListMasterdataPayload struct {
	Filter ListFilterMasterdataPayload `json:"filter"`
	Limit  int32                       `json:"limit" valid:"required~limit is required field"`
	Page   int32                       `json:"page"`
	Order  string                      `json:"order" valid:"required~order is required field"`
	Sort   string                      `json:"sort" valid:"required~sort is required field"`
}

func (payload *ListMasterdataPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListMasterdataPayload) ToEntity() (data query.ListMasterdataParams) {

	data = query.ListMasterdataParams{
		SetCategory: translateBoolIntoNumber(payload.Filter.SetCategory),
		Category:    queryStringLike(payload.Filter.Category),
		SetValue1:   translateBoolIntoNumber(payload.Filter.SetValue1),
		Value1:      queryStringLike(payload.Filter.Value1),
		SetValue2:   translateBoolIntoNumber(payload.Filter.SetValue2),
		SetParentID: translateBoolIntoNumber(payload.Filter.SetParentID),
		LimitData:   limitWithDefault(payload.Limit),
		OffsetPages: payload.Page,
		OrderParam:  makeOrderParam(payload.Order, payload.Sort),
	}

	if payload.Filter.Value2 != nil {
		if *payload.Filter.Value2 != "" {
			data.Value2 = sql.NullString{
				String: queryStringLike(*payload.Filter.Value2),
				Valid:  true,
			}
		}
	}

	if payload.Filter.ParentID != nil {
		if *payload.Filter.ParentID != 0 {
			data.ParentID = sql.NullInt64{
				Int64: *payload.Filter.ParentID,
				Valid: true,
			}
		}
	}

	return
}
