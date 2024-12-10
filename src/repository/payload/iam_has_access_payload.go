package payload

import (
	"context"
	"database/sql"

	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
)

type CreateIamHasAccessPayload struct {
	IsCreate      *bool  `json:"is_create"`
	IsRead        *bool  `json:"is_read"`
	IsUpdate      *bool  `json:"is_update"`
	IsDelete      *bool  `json:"is_delete"`
	IsCustom1     *bool  `json:"is_custom1"`
	IsCustom2     *bool  `json:"is_custom2"`
	IsCustom3     *bool  `json:"is_custom3"`
	IamAccessGUID string `json:"iam_access_guid"`
	SidebarGUID   string `json:"sidebar_guid"`
}

func (payload *CreateIamHasAccessPayload) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return nil
}

func (payload *CreateIamHasAccessPayload) ToEntity() (data query.InsertIamHasAccessParams) {

	data = query.InsertIamHasAccessParams{
		IamAccessGUID: payload.IamAccessGUID,
		SidebarGUID:   payload.SidebarGUID,
	}
	if payload.IsCreate != nil {
		data.IsCreate = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCreate),
		}
	}
	if payload.IsRead != nil {
		data.IsRead = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsRead),
		}
	}
	if payload.IsUpdate != nil {
		data.IsUpdate = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsUpdate),
		}
	}
	if payload.IsDelete != nil {
		data.IsDelete = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsDelete),
		}
	}
	if payload.IsCustom1 != nil {
		data.IsCustom1 = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCustom1),
		}
	}
	if payload.IsCustom2 != nil {
		data.IsCustom2 = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCustom2),
		}
	}
	if payload.IsCustom3 != nil {
		data.IsCustom3 = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCustom3),
		}
	}

	return
}

type UpdateIamHasAccessPayload struct {
	IsCreate      *bool  `json:"is_create"`
	IsRead        *bool  `json:"is_read"`
	IsUpdate      *bool  `json:"is_update"`
	IsDelete      *bool  `json:"is_delete"`
	IsCustom1     *bool  `json:"is_custom1"`
	IsCustom2     *bool  `json:"is_custom2"`
	IsCustom3     *bool  `json:"is_custom3"`
	IamAccessGUID string `json:"iam_access_guid"`
	SidebarGUID   string `json:"sidebar_guid"`
}

func (payload *UpdateIamHasAccessPayload) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

func (payload *UpdateIamHasAccessPayload) ToEntity(guid string) (data query.UpdateIamHasAccessParams) {

	data = query.UpdateIamHasAccessParams{
		GUID:            guid,
		IamGUID:         payload.IamAccessGUID,
		SidebarMenuGUID: payload.SidebarGUID,
	}

	if payload.IsCreate != nil {
		data.IsCreate = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCreate),
		}
	}
	if payload.IsRead != nil {
		data.IsRead = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsRead),
		}
	}
	if payload.IsUpdate != nil {
		data.IsUpdate = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsUpdate),
		}
	}
	if payload.IsDelete != nil {
		data.IsDelete = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsDelete),
		}
	}
	if payload.IsCustom1 != nil {
		data.IsCustom1 = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCustom1),
		}
	}
	if payload.IsCustom2 != nil {
		data.IsCustom2 = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCustom2),
		}
	}
	if payload.IsCustom3 != nil {
		data.IsCustom3 = sql.NullInt32{
			Valid: true,
			Int32: translateBoolIntoNumber(*payload.IsCustom3),
		}
	}

	return
}

type ListFilterIamHasAccessPayload struct {
	SetIsCreate      bool   `json:"set_is_create"`
	IsCreate         bool   `json:"is_create"`
	SetIsRead        bool   `json:"set_is_read"`
	IsRead           bool   `json:"is_read"`
	SetIsUpdate      bool   `json:"set_is_update"`
	IsUpdate         bool   `json:"is_update"`
	SetIsDelete      bool   `json:"set_is_delete"`
	IsDelete         bool   `json:"is_delete"`
	SetIsCustom1     bool   `json:"set_is_custom1"`
	IsCustom1        bool   `json:"is_custom1"`
	SetIsCustom2     bool   `json:"set_is_custom2"`
	IsCustom2        bool   `json:"is_custom2"`
	SetIsCustom3     bool   `json:"set_is_custom3"`
	IsCustom3        bool   `json:"is_custom3"`
	SetIamAccessGUID bool   `json:"set_iam_access_guid"`
	IamAccessGUID    string `json:"iam_access_guid"`
	SetSidebarGUID   bool   `json:"set_sidebar_guid"`
	SidebarGUID      string `json:"sidebar_guid"`
}

type ListIamHasAccessPayload struct {
	Filter ListFilterIamHasAccessPayload `json:"filter"`
	Limit  int32                         `json:"limit" valid:"required~limit is required field"`
	Page   int32                         `json:"page"`
	Order  string                        `json:"order" valid:"required~order is required field"`
	Sort   string                        `json:"sort" valid:"required~sort is required field"`
}

func (payload *ListIamHasAccessPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListIamHasAccessPayload) ToEntity() (data query.ListIamHasAccessParams) {

	data = query.ListIamHasAccessParams{
		SetIsCreate:      translateBoolIntoNumber(payload.Filter.SetIsCreate),
		IsCreate:         translateBoolIntoNumber(payload.Filter.IsCreate),
		SetIsRead:        translateBoolIntoNumber(payload.Filter.SetIsRead),
		IsRead:           translateBoolIntoNumber(payload.Filter.IsRead),
		SetIsUpdate:      translateBoolIntoNumber(payload.Filter.SetIsUpdate),
		IsUpdate:         translateBoolIntoNumber(payload.Filter.IsUpdate),
		SetIsDelete:      translateBoolIntoNumber(payload.Filter.SetIsDelete),
		IsDelete:         translateBoolIntoNumber(payload.Filter.IsDelete),
		SetIsCustom1:     translateBoolIntoNumber(payload.Filter.SetIsCustom1),
		IsCustom1:        translateBoolIntoNumber(payload.Filter.IsCustom1),
		SetIsCustom2:     translateBoolIntoNumber(payload.Filter.SetIsCustom2),
		IsCustom2:        translateBoolIntoNumber(payload.Filter.IsCustom2),
		SetIsCustom3:     translateBoolIntoNumber(payload.Filter.SetIsCustom3),
		IsCustom3:        translateBoolIntoNumber(payload.Filter.IsCustom3),
		SetIamAccessGUID: translateBoolIntoNumber(payload.Filter.SetIamAccessGUID),
		IamAccessGUID:    payload.Filter.IamAccessGUID,
		SetSidebarGUID:   translateBoolIntoNumber(payload.Filter.SetSidebarGUID),
		SidebarGUID:      payload.Filter.SidebarGUID,
		LimitData:        limitWithDefault(payload.Limit),
		OffsetPages:      payload.Page,
		OrderParam:       makeOrderParam(payload.Order, payload.Sort),
	}
	return
}
