package payload

import (
	"context"

	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
)

type CreateIamAccessParams struct {
	IsNotification bool   `json:"is_notification"`
	RoleGUID       string `json:"role_guid"`
}

type GetRoleMenuAccessParams struct {
	IAMAccessGuid string `json:"iam_access_guid" query:"iam_access_guid"`
	RoleGuid      string `json:"role_guid" query:"role_guid"`
}

func (payload *CreateIamAccessParams) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return nil
}

func (payload *GetRoleMenuAccessParams) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return nil
}

func (payload *CreateIamAccessParams) ToEntity(guid string) (data query.InsertIamAccessParams) {

	data = query.InsertIamAccessParams{
		IsNotification: translateBoolIntoNumber(payload.IsNotification),
		RoleGUID:       payload.RoleGUID,
		CreatedBy:      guid,
	}

	return
}

type UpdateIamAccessParams struct {
	IsNotification bool `json:"is_notification"`
}

func (payload *UpdateIamAccessParams) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

func (payload *UpdateIamAccessParams) ToEntity(guid, updatedBy string) (data query.UpdateIamAccessParams) {

	data = query.UpdateIamAccessParams{
		GUID:           guid,
		IsNotification: translateBoolIntoNumber(payload.IsNotification),
		UpdatedBy:      updatedBy,
	}
	return
}

type ListFilterIamAccessParams struct {
	SetIsNotification bool   `json:"set_is_notification"`
	IsNotification    bool   `json:"is_notification"`
	SetRoleGUID       bool   `json:"set_role_guid"`
	RoleGUID          string `json:"role_guid"`
	SetCreatedBy      bool   `json:"set_created_by"`
	CreatedBy         string `json:"created_by"`
}

type ListIamAccessParams struct {
	Filter ListFilterIamAccessParams `json:"filter"`
	Limit  int32                     `json:"limit" valid:"required~limit is required field"`
	Page   int32                     `json:"page"`
	Order  string                    `json:"order" valid:"required~order is required field"`
	Sort   string                    `json:"sort" valid:"required~sort is required field"`
}

func (payload *ListIamAccessParams) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListIamAccessParams) ToEntity() (data query.ListIamAccessParams) {

	data = query.ListIamAccessParams{
		SetIsNotification: translateBoolIntoNumber(payload.Filter.SetIsNotification),
		IsNotification:    translateBoolIntoNumber(payload.Filter.IsNotification),
		SetRoleGUID:       translateBoolIntoNumber(payload.Filter.SetRoleGUID),
		RoleGUID:          payload.Filter.RoleGUID,
		SetCreatedBy:      translateBoolIntoNumber(payload.Filter.SetCreatedBy),
		CreatedBy:         payload.Filter.CreatedBy,
		LimitData:         limitWithDefault(payload.Limit),
		OffsetPages:       payload.Page,
		OrderParam:        makeOrderParam(payload.Order, payload.Sort),
	}
	return
}
