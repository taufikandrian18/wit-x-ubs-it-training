package application

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"

	"gitlab.com/wit-id/test/src/iamaccess/service"
	"gitlab.com/wit-id/test/src/middleware"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteIamAccess(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewIamAccessService(s.GetDB(), s.GetConnectionString(), cfg)
	mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)
	menus := e.Group("/iam_access")
	menus.Use(mddw.ValidateToken)
	menus.Use(mddw.ValidateUserLogin)
	menus.GET("", func(c echo.Context) error {
		return c.String(http.StatusOK, "menu service ok")
	})

	menus.POST("", createIamAccess(svc, cfg))
	menus.PUT("/:guid", updateIamAccess(svc, cfg))
	menus.DELETE("/:guid", deleteIamAccess(svc, cfg))
	menus.GET("/:guid", getIamAccess(svc, cfg))
	menus.POST("/list", listIamAccess(svc, cfg))
	menus.GET("/", getRoleMenu(svc, cfg))
}

func createIamAccess(svc *service.IamAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.CreateIamAccessParams
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.CreateIamAccess(ctx.Request().Context(), request.ToEntity(ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func updateIamAccess(svc *service.IamAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.UpdateIamAccessParams
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

		data, err := svc.UpdateIamAccess(ctx.Request().Context(), request.ToEntity(guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func deleteIamAccess(svc *service.IamAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		err := svc.DeleteIamAccess(ctx.Request().Context(), guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}

func getIamAccess(svc *service.IamAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		resp, err := svc.GetIamAccess(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, resp, nil)
	}
}

func listIamAccess(svc *service.IamAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.ListIamAccessParams
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.ListIamAccess(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func getRoleMenu(svc *service.IamAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.GetRoleMenuAccessParams
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		if request.IAMAccessGuid != "" && request.RoleGuid != "" {
			return errors.WithStack(httpservice.ErrIamAccessParamChooseOne)
		}

		if request.IAMAccessGuid == "" && request.RoleGuid == "" {
			return errors.WithStack(httpservice.ErrIamAccessParamMustBeFilled)
		}

		resp, err := svc.GetRoleMenuAccess(ctx.Request().Context(), request.IAMAccessGuid, request.RoleGuid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, resp, nil)
	}
}
