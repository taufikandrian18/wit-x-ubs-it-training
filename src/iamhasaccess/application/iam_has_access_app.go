package application

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"

	"gitlab.com/wit-id/test/src/iamhasaccess/service"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteIamHasAccess(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewIamHasAccessService(s.GetDB(), s.GetConnectionString(), cfg)
	//mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)
	menus := e.Group("/iam_has_access")
	// menus.Use(mddw.ValidateToken)
	// menus.Use(mddw.ValidateUserLogin)
	menus.GET("", func(c echo.Context) error {
		return c.String(http.StatusOK, "menu service ok")
	})

	menus.POST("", createIamHasAccess(svc, cfg))
	menus.PUT("/:guid", updateIamHasAccess(svc, cfg))
	menus.DELETE("/:guid", deleteIamHasAccess(svc, cfg))
	menus.GET("/:guid", getIamHasAccess(svc, cfg))
	menus.POST("/list", listIamHasAccess(svc, cfg))
}

func createIamHasAccess(svc *service.IamHasAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.CreateIamHasAccessPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.CreateIamHasAccess(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func updateIamHasAccess(svc *service.IamHasAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.UpdateIamHasAccessPayload
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

		data, err := svc.UpdateIamHasAccess(ctx.Request().Context(), request.ToEntity(guid))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func deleteIamHasAccess(svc *service.IamHasAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		err := svc.DeleteIamHasAccess(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}

func getIamHasAccess(svc *service.IamHasAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		resp, err := svc.GetIamHasAccess(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, resp, nil)
	}
}

func listIamHasAccess(svc *service.IamHasAccessService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.ListIamHasAccessPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.ListIamHasAccess(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}
