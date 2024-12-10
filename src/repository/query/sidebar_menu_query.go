package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertSidebarMenuEntity struct {
	Code         string         `db:"code"`
	Text         string         `db:"text_sidebar"`
	Icon         string         `db:"icon"`
	HasPage      int            `db:"has_page"`
	UrlPath      sql.NullString `db:"url_path"`
	Level        int32          `db:"level_sidebar"`
	ParentMenuID sql.NullInt64  `db:"parent_menu_id"`
	Slug         string         `db:"slug"`
	Status       string         `db:"status"`
	CreatedBy    string         `db:"created_by"`
}

func (q *Queries) InsertSidebarMenu(ctx context.Context, arg InsertSidebarMenuEntity) (res json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var dbRes, errStr string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.insert_sidebar_menu(
				:2,:3,:4,:5,:6,:7,:8,:9,:10,:11
			);
		END;
	`,
		sql.Out{Dest: &dbRes},
		arg.Code,
		arg.Text,
		arg.Icon,
		arg.HasPage,
		arg.UrlPath,
		arg.Slug,
		arg.Level,
		sql.NullInt64{Int64: arg.ParentMenuID.Int64, Valid: arg.ParentMenuID.Valid},
		arg.CreatedBy,
		sql.Out{Dest: &errStr},
	)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	if errStr != "" {
		if errStr == constants.OracleConstraintViolation {
			log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
			err = errors.WithStack(httpservice.ErrConstraintVioaltion)
			return
		}
		log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	res = json.RawMessage(dbRes)

	return
}

type UpdateSidebarMenuEntity struct {
	GUID         string         `db:"guid"`
	Code         string         `db:"code"`
	Text         string         `db:"text_sidebar"`
	Icon         string         `db:"icon"`
	HasPage      int            `db:"has_page"`
	UrlPath      sql.NullString `db:"url_path"`
	Level        int32          `db:"level_sidebar"`
	ParentMenuID sql.NullInt64  `db:"parent_menu_id"`
	OrderNumber  int64          `db:"order_number"`
	Slug         string         `db:"slug"`
	Status       string         `db:"status"`
	UpdatedBy    string         `db:"updated_by"`
}

func (q *Queries) UpdateSidebarMenu(ctx context.Context, arg UpdateSidebarMenuEntity) (res json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var dbRes, errStr string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.update_sidebar_menu(
				:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13
			);
		END;
	`,
		sql.Out{Dest: &dbRes},
		arg.GUID,
		arg.Code,
		arg.Text,
		arg.Icon,
		arg.HasPage,
		arg.UrlPath,
		arg.Slug,
		arg.Level,
		sql.NullInt64{Int64: arg.ParentMenuID.Int64, Valid: arg.ParentMenuID.Valid},
		arg.OrderNumber,
		arg.UpdatedBy,
		sql.Out{Dest: &errStr},
	)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update sidebar menu")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	if errStr != "" {
		if errStr == constants.OracleConstraintViolation {
			log.FromCtx(ctx).Error(err, "failed update sidebar menu")
			err = errors.WithStack(httpservice.ErrConstraintVioaltion)
			return
		}
		log.FromCtx(ctx).Error(err, "failed update sidebar menu")
		err = errors.WithStack(httpservice.ErrBadRequest)
		return
	}
	res = json.RawMessage(dbRes)

	return
}

type DeleteSidebarMenuEntity struct {
	GUID      string `db:"guid"`
	DeletedBy string `db:"deleted_by"`
}

func (q *Queries) DeleteSidebarMenu(ctx context.Context, arg DeleteSidebarMenuEntity) (err error) {
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
			UBS_TRAINING.delete_sidebar_menu(
				:1,
				:2
			);
		END;
	`,
		arg.GUID,
		arg.DeletedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed delete sidebar menu")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type GetSidebarMenuParams struct {
	Guid string `json:"guid"`
}

func (q *Queries) GetSidebarMenu(ctx context.Context, arg GetMasterdataParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.get_sidebar_menu_by_guid(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Guid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get sidebar menu")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type ListSidebarMenuParams struct {
	SetCode         int32         `db:"set_code"`
	Code            string        `db:"code"`
	SetTextSidebar  int32         `db:"set_name"`
	TextSidebar     string        `db:"name"`
	SetLevelSidebar int32         `db:"set_departement_guid"`
	LevelSidebar    sql.NullInt64 `db:"departement_guid"`
	SetParentID     int32         `db:"set_parent_id"`
	ParentID        sql.NullInt64 `db:"parent_id"`
	LimitData       int32         `db:"limit_data"`
	OffsetPages     int32         `db:"offset_pages"`
	OrderParam      string        `db:"order_param"`
}

func (q *Queries) ListSidebarMenu(ctx context.Context, arg ListSidebarMenuParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.list_sidebarmenu(
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
				:12
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.SetCode,
		arg.Code,
		arg.SetTextSidebar,
		arg.TextSidebar,
		arg.SetLevelSidebar,
		arg.LevelSidebar,
		arg.SetParentID,
		arg.ParentID,
		arg.LimitData,
		arg.OffsetPages,
		arg.OrderParam,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed list sidebarmenu")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

func (q *Queries) ListMenuTree(ctx context.Context) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.LIST_SIDEBAR_TREE(
				1,NULL
			);
		END;
	`,
		sql.Out{Dest: &resultString},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get sidebar menu")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

func (q *Queries) ListSidebarAccess(ctx context.Context, iamAccessGuid string) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.LIST_SIDEBAR_ACCESS(
				:2,1,NULL
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		iamAccessGuid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get sidebar access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

func (q *Queries) GetRoleSidebarAccessMenu(ctx context.Context, iamAccessGuid string, roleGuid string) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.GET_ROLE_MENU(
				:2,:3
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		iamAccessGuid,
		roleGuid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get role menu access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}
