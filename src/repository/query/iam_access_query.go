package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertIamAccessParams struct {
	IsNotification int32  `db:"is_notification"`
	RoleGUID       string `db:"role_guid"`
	CreatedBy      string `db:"created_by"`
}

func (q *Queries) InsertIamAccess(ctx context.Context, data InsertIamAccessParams) (response json.RawMessage, err error) {
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
	var empty string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.insert_iam_access(
				:2, :3, :4,:5
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		data.IsNotification,
		data.RoleGUID,
		data.CreatedBy,
		sql.Out{Dest: &empty},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert iam access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type UpdateIamAccessParams struct {
	GUID           string `db:"guid"`
	IsNotification int32  `db:"is_notification"`
	UpdatedBy      string `db:"updated_by"`
}

func (q *Queries) UpdateIamAccess(ctx context.Context, data UpdateIamAccessParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.update_iam_access(
				:2, :3, :4
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		data.GUID,
		data.IsNotification,
		data.UpdatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update iam access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type DeleteIamAccessParams struct {
	GUID      string `db:"guid"`
	DeletedBy string `db:"deleted_by"`
}

func (q *Queries) DeleteIamAccess(ctx context.Context, arg DeleteIamAccessParams) (err error) {
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
			UBS_TRAINING.delete_iam_access(
				:1,
				:2
			);
		END;
	`,
		arg.GUID,
		arg.DeletedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed delete masterdata")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type GetIamAccessParams struct {
	Guid string `json:"guid"`
}

func (q *Queries) GetIamAccess(ctx context.Context, arg GetIamAccessParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.get_iam_access_by_guid(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Guid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type ListIamAccessParams struct {
	SetIsNotification int32  `db:"set_is_notification"`
	IsNotification    int32  `db:"is_notification"`
	SetRoleGUID       int32  `db:"set_role_guid"`
	RoleGUID          string `db:"role_guid"`
	SetCreatedBy      int32  `db:"set_created_by"`
	CreatedBy         string `db:"created_by"`
	LimitData         int32  `db:"limit_data"`
	OffsetPages       int32  `db:"offset_pages"`
	OrderParam        string `db:"order_param"`
}

func (q *Queries) ListIamAccess(ctx context.Context, arg ListIamAccessParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.list_iam_access(
				:2,
				:3,
				:4,
				:5,
				:6,
				:7,
				:8,
				:9,
				:10
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.SetIsNotification,
		arg.IsNotification,
		arg.SetRoleGUID,
		arg.RoleGUID,
		arg.SetCreatedBy,
		arg.CreatedBy,
		arg.LimitData,
		arg.OffsetPages,
		arg.OrderParam,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed list iam access")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}
