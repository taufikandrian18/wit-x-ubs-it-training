package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertIamHasAccessParams struct {
	IsCreate      sql.NullInt32 `db:"is_create"`
	IsRead        sql.NullInt32 `db:"is_read"`
	IsUpdate      sql.NullInt32 `db:"is_update"`
	IsDelete      sql.NullInt32 `db:"is_delete"`
	IsCustom1     sql.NullInt32 `db:"is_custom1"`
	IsCustom2     sql.NullInt32 `db:"is_custom2"`
	IsCustom3     sql.NullInt32 `db:"is_custom3"`
	IamAccessGUID string        `db:"iam_access_guid"`
	SidebarGUID   string        `db:"sidebar_guid"`
}

func (q *Queries) InsertIamHasAccess(ctx context.Context, data InsertIamHasAccessParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.insert_iam_has_access(
				:2, :3, :4,:5,:6,:7,:8,:9,:10
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		data.IsCreate,
		data.IsRead,
		data.IsUpdate,
		data.IsDelete,
		data.IsCustom1,
		data.IsCustom2,
		data.IsCustom3,
		data.IamAccessGUID,
		data.SidebarGUID,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert iam access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type UpdateIamHasAccessParams struct {
	GUID            string        `db:"guid"`
	IsCreate        sql.NullInt32 `db:"is_create"`
	IsRead          sql.NullInt32 `db:"is_read"`
	IsUpdate        sql.NullInt32 `db:"is_update"`
	IsDelete        sql.NullInt32 `db:"is_delete"`
	IsCustom1       sql.NullInt32 `db:"is_custom1"`
	IsCustom2       sql.NullInt32 `db:"is_custom2"`
	IsCustom3       sql.NullInt32 `db:"is_custom3"`
	IamGUID         string        `db:"iam_guid"`
	SidebarMenuGUID string        `db:"sidebar_menu_guid"`
}

func (q *Queries) UpdateIamHasAccess(ctx context.Context, data UpdateIamHasAccessParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.update_iam_has_access(
				:2, :3, :4,:5,:6,:7,:8,:9,:10,:11
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		data.GUID,
		data.IsCreate,
		data.IsRead,
		data.IsUpdate,
		data.IsDelete,
		data.IsCustom1,
		data.IsCustom2,
		data.IsCustom3,
		data.IamGUID,
		data.SidebarMenuGUID,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update iam access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type DeleteAndGetIamHasAccessParams struct {
	GUID string `json:"guid"`
}

func (q *Queries) DeleteIamHasAccess(ctx context.Context, arg DeleteAndGetIamHasAccessParams) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.delete_iam_has_access(
				:1
			);
		END;
	`,
		arg.GUID,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed delete masterdata")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

func (q *Queries) GetIamHasAccess(ctx context.Context, arg DeleteAndGetIamHasAccessParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_iam_has_access_by_guid(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.GUID,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get iam has access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type ListIamHasAccessParams struct {
	SetIsCreate      int32  `db:"set_is_create"`
	IsCreate         int32  `db:"is_create"`
	SetIsRead        int32  `db:"set_is_read"`
	IsRead           int32  `db:"is_read"`
	SetIsUpdate      int32  `db:"set_is_update"`
	IsUpdate         int32  `db:"is_update"`
	SetIsDelete      int32  `db:"set_is_delete"`
	IsDelete         int32  `db:"is_delete"`
	SetIsCustom1     int32  `db:"set_is_custom1"`
	IsCustom1        int32  `db:"is_custom1"`
	SetIsCustom2     int32  `db:"set_is_custom2"`
	IsCustom2        int32  `db:"is_custom2"`
	SetIsCustom3     int32  `db:"set_is_custom3"`
	IsCustom3        int32  `db:"is_custom3"`
	SetIamAccessGUID int32  `db:"set_iam_access_guid"`
	IamAccessGUID    string `db:"iam_access_guid"`
	SetSidebarGUID   int32  `db:"set_sidebar_guid"`
	SidebarGUID      string `db:"sidebar_guid"`
	LimitData        int32  `db:"limit_data"`
	OffsetPages      int32  `db:"offset_pages"`
	OrderParam       string `db:"order_param"`
}

func (q *Queries) ListIamHasAccess(ctx context.Context, arg ListIamHasAccessParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.list_iam_has_access(
				:2,
				:3,
				:4,
				:5,
				:6,
				:7,
				:8,
				:9,
				:10,
				:11,
				:12,
				:13,
				:14,
				:15,
				:16,
				:17,
				:18,
				:19,
				:20,
				:21,
				:22
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.SetIsCreate,
		arg.IsCreate,
		arg.SetIsRead,
		arg.IsRead,
		arg.SetIsUpdate,
		arg.IsUpdate,
		arg.SetIsDelete,
		arg.IsDelete,
		arg.SetIsCustom1,
		arg.IsCustom1,
		arg.SetIsCustom2,
		arg.IsCustom2,
		arg.SetIsCustom3,
		arg.IsCustom3,
		arg.SetIamAccessGUID,
		arg.IamAccessGUID,
		arg.SetSidebarGUID,
		arg.SidebarGUID,
		arg.LimitData,
		arg.OffsetPages,
		arg.OrderParam,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed list masterdata")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}
