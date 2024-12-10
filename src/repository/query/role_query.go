package query

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertRoleIamHas struct {
	IsCreate    sql.NullInt32 `db:"is_create"`
	IsRead      sql.NullInt32 `db:"is_read"`
	IsUpdate    sql.NullInt32 `db:"is_update"`
	IsDelete    sql.NullInt32 `db:"is_delete"`
	IsCustom1   sql.NullInt32 `db:"is_custom1"`
	IsCustom2   sql.NullInt32 `db:"is_custom2"`
	IsCustom3   sql.NullInt32 `db:"is_custom3"`
	SidebarGUID string        `db:"sidebar_guid"`
}

type InsertRoleParams struct {
	RoleCode          string `db:"role_code"`
	RoleName          string `db:"role_name"`
	CreatedBy         string `db:"created_by"`
	IamIsNotification int32  `db:"iam_is_notification"`
	IamHas            []InsertRoleIamHas
}

func (q *Queries) InsertRoleAndChild(ctx context.Context, data InsertRoleParams) (response json.RawMessage, err error) {
	var dbQueryLoop string
	var resString string
	var DBErr DBError

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

	dbQueryStart := `
	DECLARE
	v_iam_has_data_table UBS_TRAINING.iam_has_req_table := UBS_TRAINING.iam_has_req_table(
	`
	for i, v := range data.IamHas {
		tempQueryLoop := fmt.Sprintf(`UBS_TRAINING.iam_has_req(%s,%s,%s,%s,%s,%s,%s,'%s')`, utility.NullIntToString(v.IsCreate), utility.NullIntToString(v.IsRead), utility.NullIntToString(v.IsUpdate), utility.NullIntToString(v.IsDelete), utility.NullIntToString(v.IsCustom1), utility.NullIntToString(v.IsCustom2), utility.NullIntToString(v.IsCustom3), v.SidebarGUID)
		if i != len(data.IamHas)-1 {
			tempQueryLoop += `,`
		}
		dbQueryLoop += tempQueryLoop
	}
	dbQueryEnd := `
	);

BEGIN
	:1 := UBS_TRAINING.INSERT_ROLE_AND_CHILD(
			:2,
			:3,
			:4,
			:5,
			v_iam_has_data_table
	);
END;
	`
	_, err = db.Exec(dbQueryStart+dbQueryLoop+dbQueryEnd,
		sql.Out{Dest: &resString},
		data.RoleCode,
		data.RoleName,
		data.CreatedBy,
		data.IamIsNotification,
	)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert role and child")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	isError, err := DBErr.Unmarshal([]byte(resString))
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed unmarshall error")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	if isError {
		log.FromCtx(ctx).Error(fmt.Errorf(DBErr.Error.Message), "failed update role")
		if DBErr.Error.Code == "-1" {
			err = errors.WithStack(httpservice.ErrRoleUnique)
		} else {
			err = errors.WithStack(httpservice.ErrInternalServerError)
		}
		return
	}

	return json.RawMessage(resString), nil

}

type UpdateRoleIamHas struct {
	IsCrud        int32         `db:"is_crud"`
	IamHasGUID    string        `db:"iam_has_guid"`
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

type UpdateRoleParams struct {
	RoleGUID          string `db:"role_guid"`
	RoleCode          string `db:"role_code"`
	RoleName          string `db:"role_name"`
	UpdatedBy         string `db:"updated_by"`
	IamIsNotification int32  `db:"iam_is_notification"`
	IamHas            []UpdateRoleIamHas
}

func (q *Queries) UpdateRoleAndChild(ctx context.Context, data UpdateRoleParams) (response json.RawMessage, err error) {
	var dbQueryLoop string
	var resString string
	var DBErr DBError

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

	dbQueryStart := `
	DECLARE
	v_iam_has_data_table UBS_TRAINING.iam_has_req_cud_table := UBS_TRAINING.iam_has_req_cud_table(
	`
	for i, v := range data.IamHas {
		tempQueryLoop := fmt.Sprintf(`UBS_TRAINING.iam_has_req_cud(%v,'%s',%s,%s,%s,%s,%s,%s,%s,'%s','%s')`, v.IsCrud, v.IamHasGUID, utility.NullIntToString(v.IsCreate), utility.NullIntToString(v.IsRead), utility.NullIntToString(v.IsUpdate), utility.NullIntToString(v.IsDelete), utility.NullIntToString(v.IsCustom1), utility.NullIntToString(v.IsCustom2), utility.NullIntToString(v.IsCustom3), v.IamAccessGUID, v.SidebarGUID)
		if i != len(data.IamHas)-1 {
			tempQueryLoop += `,`
		}
		dbQueryLoop += tempQueryLoop
	}
	dbQueryEnd := `
	);

BEGIN
	:1 := UBS_TRAINING.UPDATE_ROLE_AND_CHILD(
			:2,
			:3,
			:4,
			:5,
			:6,
			v_iam_has_data_table
	);
END;
	`
	_, err = db.Exec(dbQueryStart+dbQueryLoop+dbQueryEnd,
		sql.Out{Dest: &resString},
		data.RoleGUID,
		data.RoleCode,
		data.RoleName,
		data.UpdatedBy,
		data.IamIsNotification,
	)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update role and child")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	isError, err := DBErr.Unmarshal([]byte(resString))
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed unmarshall error")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	if isError {
		log.FromCtx(ctx).Error(fmt.Errorf(DBErr.Error.Message), "failed update role")
		if DBErr.Error.Code == "-1" {
			err = errors.WithStack(httpservice.ErrRoleUnique)
		} else {
			err = errors.WithStack(httpservice.ErrInternalServerError)
		}
		return
	}

	return json.RawMessage(resString), nil

}

type DeleteRoleParams struct {
	GUID      string `db:"guid"`
	DeletedBy string `db:"deleted_by"`
}

func (q *Queries) DeleteRole(ctx context.Context, arg DeleteRoleParams) (err error) {
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
			UBS_TRAINING.DELETE_ROLE_AND_CHILD(
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

type GetRoleParams struct {
	GUID string `json:"guid"`
}

func (q *Queries) GetRole(ctx context.Context, arg GetRoleParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.get_role_by_guid(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.GUID,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return json.RawMessage(resultString), nil
}

type ListRoleParams struct {
	SetCode     int32  `db:"set_category"`
	Code        string `db:"category"`
	SetName     int32  `db:"set_value1"`
	Name        string `db:"value1"`
	LimitData   int32  `db:"limit_data"`
	OffsetPages int32  `db:"offset_pages"`
	OrderParam  string `db:"order_param"`
}

func (q *Queries) ListRole(ctx context.Context, arg ListRoleParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.list_roles(
				:2,
				:3,
				:4,
				:5,
				:6,
				:7,
				:8
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.SetCode,
		arg.Code,
		arg.SetName,
		arg.Name,
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

type UpdateEmployeesRoleParams struct {
	StatusAction int32  `db:"status_action"`
	RoleGUID     string `db:"role_guid"`
	UpdatedBy    string `db:"updated_by"`
	UserGUID     string `db:"user_guid"`
}

func (q *Queries) UpdateEmployeesRole(ctx context.Context, arg UpdateEmployeesRoleParams) (err error) {
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
			UBS_TRAINING.UPDATE_EMPLOYEE_ROLE(
				:1,
				:2,
				:3,
				:4
			);
		END;`,
		arg.StatusAction,
		arg.RoleGUID,
		arg.UpdatedBy,
		arg.UserGUID,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type ListEmployeeByRoleParams struct {
	RoleGUID    string `db:"guid"`
	LimitData   int32  `db:"limit_data"`
	OffsetPages int32  `db:"offset_pages"`
	OrderParams string `db:"order_params"`
}

func (q *Queries) ListEmployeeByRole(ctx context.Context, arg ListEmployeeByRoleParams) (response json.RawMessage, err error) {
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
	var resString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1:=UBS_TRAINING.list_employee_by_role(
				:2,
				:3,
				:4,
				:5
			);
		END;
	`,
		sql.Out{Dest: &resString},
		arg.RoleGUID,
		arg.LimitData,
		arg.OffsetPages,
		arg.OrderParams,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return json.RawMessage(resString), nil
}
