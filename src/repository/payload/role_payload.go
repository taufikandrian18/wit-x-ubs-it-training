package payload

import (
	"context"
	"database/sql"
	"strings"

	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
)

type InsertRoleIamHasPayload struct {
	IsCreate    *bool  `json:"is_create"`
	IsRead      *bool  `json:"is_read"`
	IsUpdate    *bool  `json:"is_update"`
	IsDelete    *bool  `json:"is_delete"`
	IsCustom1   *bool  `json:"is_custom1"`
	IsCustom2   *bool  `json:"is_custom2"`
	IsCustom3   *bool  `json:"is_custom3"`
	SidebarGUID string `json:"sidebar_guid"`
}

type InsertRolePayload struct {
	RoleCode          string                    `json:"role_code"`
	RoleName          string                    `json:"role_name"`
	IamIsNotification bool                      `json:"iam_is_notification"`
	IamHas            []InsertRoleIamHasPayload `json:"iam_has"`
}

func (payload *InsertRolePayload) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return nil
}

func (payload *InsertRolePayload) ToEntity(guid string) (data query.InsertRoleParams) {

	data = query.InsertRoleParams{
		RoleCode:          payload.RoleCode,
		RoleName:          payload.RoleName,
		CreatedBy:         guid,
		IamIsNotification: translateBoolIntoNumber(payload.IamIsNotification),
	}

	for _, v := range payload.IamHas {
		temp := query.InsertRoleIamHas{
			SidebarGUID: v.SidebarGUID,
		}

		if v.IsCreate != nil {
			temp.IsCreate = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCreate),
			}
		}
		if v.IsRead != nil {
			temp.IsRead = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsRead),
			}
		}
		if v.IsUpdate != nil {
			temp.IsUpdate = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsUpdate),
			}
		}
		if v.IsDelete != nil {
			temp.IsDelete = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsDelete),
			}
		}
		if v.IsCustom1 != nil {
			temp.IsCustom1 = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCustom1),
			}
		}
		if v.IsCustom2 != nil {
			temp.IsCustom2 = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCustom2),
			}
		}
		if v.IsCustom3 != nil {
			temp.IsCustom3 = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCustom3),
			}
		}

		data.IamHas = append(data.IamHas, temp)
	}

	return
}

type UpdateRoleIamHasPayload struct {
	StatusAction  string `json:"status_action"`
	IamHasGUID    string `json:"iam_has_guid"`
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

type UpdateRolePayload struct {
	RoleCode          string                    `json:"role_code"`
	RoleName          string                    `json:"role_name"`
	IamIsNotification bool                      `json:"iam_is_notification"`
	IamHas            []UpdateRoleIamHasPayload `json:"iam_has"`
}

func (payload *UpdateRolePayload) Validate(ctx context.Context) (err error) {

	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	for _, v := range payload.IamHas {
		switch strings.ToLower(v.StatusAction) {
		case `create`:
			continue
		case `update`:
			continue
		case `delete`:
			continue
		default:
			return httpservice.ErrBadRequest
		}
	}

	return nil
}

func (payload *UpdateRolePayload) ToEntity(guid, updatedBy string) (data query.UpdateRoleParams) {
	data = query.UpdateRoleParams{
		RoleGUID:          guid,
		RoleCode:          payload.RoleCode,
		RoleName:          payload.RoleName,
		UpdatedBy:         updatedBy,
		IamIsNotification: translateBoolIntoNumber(payload.IamIsNotification),
	}

	for _, v := range payload.IamHas {
		var tempCrud int32
		switch strings.ToLower(v.StatusAction) {
		case `create`:
			tempCrud = 1
		case `update`:
			tempCrud = 2
		case `delete`:
			tempCrud = 3
		default:
			tempCrud = 1
		}
		temp := query.UpdateRoleIamHas{
			IsCrud:        tempCrud,
			IamHasGUID:    v.IamHasGUID,
			SidebarGUID:   v.SidebarGUID,
			IamAccessGUID: v.IamAccessGUID,
		}
		if v.IsCreate != nil {
			temp.IsCreate = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCreate),
			}
		}
		if v.IsRead != nil {
			temp.IsRead = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsRead),
			}
		}
		if v.IsUpdate != nil {
			temp.IsUpdate = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsUpdate),
			}
		}
		if v.IsDelete != nil {
			temp.IsDelete = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsDelete),
			}
		}
		if v.IsCustom1 != nil {
			temp.IsCustom1 = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCustom1),
			}
		}
		if v.IsCustom2 != nil {
			temp.IsCustom2 = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCustom2),
			}
		}
		if v.IsCustom3 != nil {
			temp.IsCustom3 = sql.NullInt32{
				Valid: true,
				Int32: translateBoolIntoNumber(*v.IsCustom3),
			}
		}
		data.IamHas = append(data.IamHas, temp)
	}

	return
}

type ListFilterRolePayload struct {
	SetCode bool   `json:"set_code"`
	Code    string `json:"code"`
	SetName bool   `json:"set_name"`
	Name    string `json:"name"`
}

type ListRolePayload struct {
	Filter ListFilterRolePayload `json:"filter"`
	Limit  int32                 `json:"limit" valid:"required~limit is required field"`
	Page   int32                 `json:"page"`
	Order  string                `json:"order" valid:"required~order is required field"`
	Sort   string                `json:"sort" valid:"required~sort is required field"`
}

func (payload *ListRolePayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListRolePayload) ToEntity() (data query.ListRoleParams) {
	data = query.ListRoleParams{
		SetCode:     translateBoolIntoNumber(payload.Filter.SetCode),
		Code:        queryStringLike(payload.Filter.Code),
		SetName:     translateBoolIntoNumber(payload.Filter.SetName),
		Name:        queryStringLike(payload.Filter.Name),
		LimitData:   limitWithDefault(payload.Limit),
		OffsetPages: payload.Page,
		OrderParam:  makeOrderParam(payload.Order, payload.Sort),
	}
	return
}

type UpdateEmployeesRolePayload struct {
	StatusAction string   `json:"status_action"`
	RoleGUID     string   `json:"role_guid"`
	UserGUID     []string `json:"employee_guid"`
}

func (payload *UpdateEmployeesRolePayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

func (payload *UpdateEmployeesRolePayload) ToEntity() (data query.UpdateEmployeesRoleParams) {
	data = query.UpdateEmployeesRoleParams{
		RoleGUID:  payload.RoleGUID,
		UpdatedBy: constants.CreatedByTemporaryBySystem,
		UserGUID:  strings.Join(payload.UserGUID, constants.DefaultDelimiterStringOracleValue),
	}
	if len(payload.UserGUID) == 0 {
		data.StatusAction = 2
	} else {
		data.StatusAction = 1
	}
	return
}

type ListEmployeeByRole struct {
	RoleGUID  string `json:"guid"`
	LimitData int32  `json:"limit_data"`
	Page      int32  `json:"page"`
	Order     string `json:"order"`
	Sort      string `json:"sort"`
}

func (payload *ListEmployeeByRole) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListEmployeeByRole) ToEntity() (data query.ListEmployeeByRoleParams) {
	data = query.ListEmployeeByRoleParams{
		RoleGUID:    payload.RoleGUID,
		LimitData:   payload.LimitData,
		OffsetPages: payload.Page,
		OrderParams: makeOrderParam(payload.Order, payload.Sort),
	}
	return
}
