package payload

import (
	"context"
	"database/sql"

	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
)

type CreateSidebarMenuPayload struct {
	Code         string  `json:"code" valid:"required~code is required field"`
	Text         string  `json:"text" valid:"required~text is required field"`
	Icon         string  `json:"icon"`
	HasPage      bool    `json:"has_page"`
	UrlPath      *string `json:"url_path"`
	Slug         string  `json:"slug"`
	Level        int32   `json:"level" valid:"required~level is required field"`
	ParentMenuID *int64  `json:"parent_menu_id"`
}

func (payload *CreateSidebarMenuPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	//no err handling for resp yet
	if payload.HasPage {
		if payload.UrlPath == nil {
			return httpservice.ErrSidebarURLNull
		}
		if *payload.UrlPath == `` {
			return httpservice.ErrSidebarURLNull
		}
	} else {
		if payload.UrlPath != nil {
			if *payload.UrlPath != "" {
				return httpservice.ErrSidebarURLNotNull
			}
		}
	}
	return
}

func (c *CreateSidebarMenuPayload) ToEntity(guid string) (res query.InsertSidebarMenuEntity) {

	parentID := sql.NullInt64{}
	UrlPath := sql.NullString{}
	var hasPage int

	if c.ParentMenuID != nil {
		if *c.ParentMenuID != 0 {
			parentID = sql.NullInt64{
				Valid: true,
				Int64: *c.ParentMenuID,
			}
		}
	}
	if c.UrlPath != nil {
		if *c.UrlPath != "" {
			UrlPath = sql.NullString{
				Valid:  true,
				String: *c.UrlPath,
			}
		}
	}

	if c.HasPage {
		hasPage = 1
	} else {
		hasPage = 0
	}

	res = query.InsertSidebarMenuEntity{
		Code:         c.Code,
		Text:         c.Text,
		Icon:         c.Icon,
		HasPage:      hasPage,
		UrlPath:      UrlPath,
		Level:        c.Level,
		ParentMenuID: parentID,
		Slug:         c.Slug,
		Status:       constants.StatusActive,
		CreatedBy:    guid,
	}

	return
}

type UpdateSidebarMenuPayload struct {
	Code         string  `json:"code"`
	Text         string  `json:"text"  valid:"required~text is required field"`
	Icon         string  `json:"icon"`
	HasPage      bool    `json:"has_page"`
	UrlPath      *string `json:"url_path"`
	Slug         string  `json:"slug"`
	Level        int32   `json:"level" valid:"required~level is required field"`
	ParentMenuID *int64  `json:"parent_menu_id"`
	OrderNumber  int64   `json:"order_number"`
}

func (payload *UpdateSidebarMenuPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	//no err handling for resp yet
	if payload.HasPage {
		if payload.UrlPath == nil {
			return httpservice.ErrSidebarURLNull
		}
		if *payload.UrlPath == `` {
			return httpservice.ErrSidebarURLNull
		}
	} else {
		if payload.UrlPath != nil {
			if *payload.UrlPath != "" {
				return httpservice.ErrSidebarURLNotNull
			}
		}
	}
	return
}

func (payload *UpdateSidebarMenuPayload) ToEntity(guid, updatedBy string) (res query.UpdateSidebarMenuEntity) {

	parentID := sql.NullInt64{}
	UrlPath := sql.NullString{}

	if payload.ParentMenuID != nil {
		if *payload.ParentMenuID != 0 {
			parentID = sql.NullInt64{
				Valid: true,
				Int64: *payload.ParentMenuID,
			}
		}
	}
	if payload.UrlPath != nil {
		if *payload.UrlPath != "" {
			UrlPath = sql.NullString{
				Valid:  true,
				String: *payload.UrlPath,
			}
		}
	}

	res = query.UpdateSidebarMenuEntity{
		GUID:         guid,
		Code:         payload.Code,
		Text:         payload.Text,
		Icon:         payload.Icon,
		HasPage:      int(translateBoolIntoNumber(payload.HasPage)),
		UrlPath:      UrlPath,
		Level:        payload.Level,
		ParentMenuID: parentID,
		OrderNumber:  payload.OrderNumber,
		Slug:         payload.Slug,
		Status:       constants.StatusActive,
		UpdatedBy:    updatedBy,
	}
	return
}

type ListFilterSidebarMenuPayload struct {
	SetCode         bool   `json:"set_code"`
	Code            string `json:"code"`
	SetTextSidebar  bool   `json:"set_text_sidebar"`
	TextSidebar     string `json:"text_sidebar"`
	SetLevelSidebar bool   `json:"set_level_sidebar"`
	LevelSidebar    *int64 `json:"level_sidebar"`
	SetParentID     bool   `json:"set_parent_id"`
	ParentID        *int64 `json:"parent_id"`
}

type ListSidebarMenuPayload struct {
	Filter ListFilterSidebarMenuPayload `json:"filter"`
	Limit  int32                        `json:"limit" valid:"required~limit is required field"`
	Page   int32                        `json:"page"`
	Order  string                       `json:"order" valid:"required~order is required field"`
	Sort   string                       `json:"sort" valid:"required~sort is required field"`
}

func (payload *ListSidebarMenuPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListSidebarMenuPayload) ToEntity() (data query.ListSidebarMenuParams) {

	data = query.ListSidebarMenuParams{
		SetCode:         translateBoolIntoNumber(payload.Filter.SetCode),
		Code:            queryStringLike(payload.Filter.Code),
		SetTextSidebar:  translateBoolIntoNumber(payload.Filter.SetTextSidebar),
		TextSidebar:     queryStringLike(payload.Filter.TextSidebar),
		SetLevelSidebar: translateBoolIntoNumber(payload.Filter.SetLevelSidebar),
		SetParentID:     translateBoolIntoNumber(payload.Filter.SetParentID),
		LimitData:       payload.Limit,
		OffsetPages:     payload.Page,
		OrderParam:      makeOrderParam(payload.Order, payload.Sort),
	}

	if payload.Filter.ParentID != nil {
		if *payload.Filter.ParentID != 0 {
			data.ParentID = sql.NullInt64{
				Int64: *payload.Filter.ParentID,
				Valid: true,
			}
		}
	}
	if payload.Filter.LevelSidebar != nil {
		if *payload.Filter.LevelSidebar != 0 {
			data.LevelSidebar = sql.NullInt64{
				Int64: *payload.Filter.LevelSidebar,
				Valid: true,
			}
		}
	}

	return
}
