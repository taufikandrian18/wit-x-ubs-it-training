package application

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"

	"gitlab.com/wit-id/test/src/middleware"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/role/service"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteRole(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewRoleService(s.GetDB(), s.GetConnectionString(), cfg)
	mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)
	menus := e.Group("/role")
	menus.Use(mddw.ValidateToken)
	menus.Use(mddw.ValidateUserLogin)
	menus.GET("", func(c echo.Context) error {
		return c.String(http.StatusOK, "menu service ok")
	})

	menus.POST("", createRoleAndChild(svc, cfg))
	menus.PUT("/:guid", updateRoleAndChild(svc, cfg))
	menus.DELETE("/:guid", deleteRoleAndChild(svc, cfg))
	menus.GET("/:guid", getRole(svc, cfg))
	menus.POST("/list", listRole(svc, cfg))
	menus.PUT("/list/employee", updateEmployeesRole(svc, cfg))
	menus.POST("/list/employee", listEmployeeByRole(svc, cfg))
}

func createRoleAndChild(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.InsertRolePayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.InsertRoleAndChild(ctx.Request().Context(), request.ToEntity(ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func updateRoleAndChild(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.UpdateRolePayload
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.UpdateRoleAndChild(ctx.Request().Context(), request.ToEntity(guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func deleteRoleAndChild(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		err := svc.DeleteRoleAndChild(ctx.Request().Context(), guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}

func getRole(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		resp, err := svc.GetRole(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, resp, nil)
	}
}

func listRole(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.ListRolePayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.ListRole(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}
func listEmployeeByRole(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.ListEmployeeByRole
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.ListEmployeeByRole(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func updateEmployeesRole(svc *service.RoleService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.UpdateEmployeesRolePayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		err := svc.UpdateEmployeesRole(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}
