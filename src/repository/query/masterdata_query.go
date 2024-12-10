package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertMasterDataParams struct {
	Category  string         `db:"category"`
	Value1    string         `db:"value_1"`
	Value2    sql.NullString `db:"value_2"`
	ParentID  sql.NullInt64  `db:"parent_id"`
	CreatedBy string         `db:"created_by"`
}

func (q *Queries) InsertMasterData(ctx context.Context, data InsertMasterDataParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.insert_masterdata_value(
				:2, :3, :4,:5,:6
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		data.Category,
		data.Value1,
		sql.NullString{Valid: data.Value2.Valid, String: data.Value2.String},
		sql.NullInt64{Valid: data.ParentID.Valid, Int64: data.ParentID.Int64},
		data.CreatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert master data")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type UpdateMasterdataParams struct {
	GUID        string         `db:"guid"`
	Category    string         `db:"category"`
	Value1      string         `db:"value_1"`
	Value2      sql.NullString `db:"value_2"`
	ParentID    sql.NullInt64  `db:"parent_id"`
	OrderNumber int64          `db:"order_number"`
	UpdatedBy   string         `db:"updated_by"`
}

func (q *Queries) UpdateMasterData(ctx context.Context, data UpdateMasterdataParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.update_masterdata_value(
				:2, :3, :4,:5,:6,:7,:8
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		data.GUID,
		data.Category,
		data.Value1,
		sql.NullString{Valid: data.Value2.Valid, String: data.Value2.String},
		sql.NullInt64{Valid: data.ParentID.Valid, Int64: data.ParentID.Int64},
		data.OrderNumber,
		data.UpdatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update master data")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type DeleteMasterDataParams struct {
	GUID      string `db:"guid"`
	DeletedBy string `db:"deleted_by"`
}

func (q *Queries) DeleteMasterdata(ctx context.Context, arg DeleteMasterDataParams) (err error) {
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
			UBS_TRAINING.delete_masterdata_value(
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

type GetMasterdataParams struct {
	Guid string `json:"guid"`
}

func (q *Queries) GetMasterdata(ctx context.Context, arg GetMasterdataParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.get_masterdata_value_by_guid(
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

type ListMasterdataParams struct {
	SetCategory int32          `db:"set_category"`
	Category    string         `db:"category"`
	SetValue1   int32          `db:"set_value1"`
	Value1      string         `db:"value1"`
	SetValue2   int32          `db:"set_value2"`
	Value2      sql.NullString `db:"value2"`
	SetParentID int32          `db:"set_parent_id"`
	ParentID    sql.NullInt64  `db:"parent_id"`
	LimitData   int32          `db:"limit_data"`
	OffsetPages int32          `db:"offset_pages"`
	OrderParam  string         `db:"order_param"`
}

func (q *Queries) ListMasterdata(ctx context.Context, arg ListMasterdataParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.list_masterdata_values(
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
		arg.SetCategory,
		arg.Category,
		arg.SetValue1,
		arg.Value1,
		arg.SetValue2,
		arg.Value2,
		arg.SetParentID,
		arg.ParentID,
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
