package middleware

import (
	"context"
	"encoding/json"

	"gitlab.com/wit-id/test/src/repository/query"
)

type IAMAccessPayload struct {
	EmployeeGUID string
}

type ReadIAM struct {
	RoleName       string         `json:"role_name"`
	RoleCode       string         `json:"role_code"`
	IamAccessGUID  string         `json:"iam_access_guid"`
	IsNotification int32          `json:"is_notification"`
	IamHas         []IamHasCommon `json:"iam_has"`
}

type IamHasCommon struct {
	ID              int32  `json:"id"`
	GUID            string `json:"guid"`
	SidebarMenuGUID string `json:"sidebar_menu_guid"`
	IsCreate        *int32 `json:"is_create"`
	IsRead          *int32 `json:"is_read"`
	IsUpdate        *int32 `json:"is_update"`
	IsDelete        *int32 `json:"is_delete"`
	IsCustom1       *int32 `json:"is_custom_1"`
	IsCustom2       *int32 `json:"is_custom_2"`
	IsCustom3       *int32 `json:"is_custom_3"`
}

func (i *ReadIAM) ConvertToReadIAM(req json.RawMessage) (err error) {
	err = json.Unmarshal(req, &i)
	return
}

func (i *ReadIAM) ConvertIamHas(req json.RawMessage) (err error) {
	err = json.Unmarshal(req, &i.IamHas)
	return
}

func (v *EnsureToken) getIAMAccessToken(ctx context.Context, request IAMAccessPayload) (iamData ReadIAM, err error) {
	q := query.New(v.connectionString)

	iamRes, err := q.IamAccessMiddleware(ctx, query.IamAccessMiddlewareParams{
		EmployeeGUID: request.EmployeeGUID,
	})
	if err != nil {
		return
	}

	err = iamData.ConvertToReadIAM(iamRes)
	if err != nil {
		return
	}

	hasRes, err := q.IamHasAccessMiddleware(ctx, query.IamHasAccessMiddlewareParams{
		IamAccessGUID: iamData.IamAccessGUID,
	})
	if err != nil {
		return
	}
	err = iamData.ConvertIamHas(hasRes)
	if err != nil {
		return
	}
	// q := sqlc.New(v.mainDB)

	// var filterIAM sqlc.GetIAMAccessMddwParams
	// var hasAccessDropdown payload.HasAccessDropdown

	// if request.JobID != "" {
	// 	filterIAM.SetJobID = true
	// 	filterIAM.JobID = request.JobID
	// }

	// // if request.PropertyID != "" {
	// // 	filterIAM.SetPropertyID = true
	// // 	filterIAM.PropertyID = sql.NullString{
	// // 		String: request.PropertyID,
	// // 		Valid:  true,
	// // 	}
	// // }

	// if request.BrandID != "" {
	// 	filterIAM.SetBrandID = true
	// 	filterIAM.BrandID = sql.NullString{
	// 		String: request.BrandID,
	// 		Valid:  true,
	// 	}
	// }

	// if request.GroupID != "" {
	// 	filterIAM.SetGroupID = true
	// 	filterIAM.GroupID = sql.NullString{
	// 		String: request.GroupID,
	// 		Valid:  true,
	// 	}
	// }

	// data, err := q.GetIAMAccessMddw(context.Background(), filterIAM)
	// if err != nil {
	// 	return
	// }

	// hasAccess, err := q.GetIAMHasAccess(context.Background(), data.Guid)
	// if err != nil {
	// 	return
	// }

	// dataGroup, err := q.GetMasterdataValues(context.Background(), request.GroupID)
	// if err != nil {
	// 	return
	// }

	// if strings.ToLower(dataGroup.Value) == constants.GroupCorporate {
	// 	hasAccessDropdown = payload.HasAccessDropdown{
	// 		Group:    true,
	// 		Brand:    true,
	// 		Property: true,
	// 	}
	// } else if request.PropertyID != "" {
	// 	hasAccessDropdown = payload.HasAccessDropdown{
	// 		Group:    false,
	// 		Brand:    false,
	// 		Property: false,
	// 	}
	// } else {
	// 	hasAccessDropdown = payload.HasAccessDropdown{
	// 		Group:    false,
	// 		Brand:    false,
	// 		Property: true,
	// 	}
	// }

	// iamData = payload.ToPayloadIAM(sqlc.GetIAMAccessRow(data))
	// // iamData.MenuAccess = payload.BuildMenuItems(payload.ToPayloadIAMHasAccess(hasAccess))
	// iamData.MenuAccess = payload.ToPayloadIAMHasAccess(hasAccess, []sqlc.ListMenuRow{})
	// iamData.HasAccessDropdown = hasAccessDropdown

	return
}
