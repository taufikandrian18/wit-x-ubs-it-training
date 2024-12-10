package application

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"

	"gitlab.com/wit-id/test/src/masterdata/service"
	"gitlab.com/wit-id/test/src/middleware"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteMasterdata(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewMasterDataService(s.GetDB(), s.GetConnectionString(), cfg)
	mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)
	menus := e.Group("/masterdata")
	menus.Use(mddw.ValidateToken)
	menus.Use(mddw.ValidateUserLogin)
	menus.GET("", func(c echo.Context) error {
		return c.String(http.StatusOK, "menu service ok")
	})

	menus.POST("", createMasterdata(svc, cfg))
	menus.PUT("/:guid", updateMasterdata(svc, cfg))
	menus.DELETE("/:guid", deleteMasterdata(svc, cfg))
	menus.GET("/:guid", getMasterdata(svc, cfg))
	menus.POST("/list", listMasterdata(svc, cfg))
}

func createMasterdata(svc *service.MasterDataService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.CreateMasterdataPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.InsertMasterData(ctx.Request().Context(), request.ToEntity(ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func updateMasterdata(svc *service.MasterDataService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.UpdateMasterdataPayload
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

		data, err := svc.UpdateMasterData(ctx.Request().Context(), request.ToEntity(guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func deleteMasterdata(svc *service.MasterDataService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		err := svc.DeleteMasterdata(ctx.Request().Context(), guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}

func getMasterdata(svc *service.MasterDataService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		resp, err := svc.GetMasterdata(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, resp, nil)
	}
}

func listMasterdata(svc *service.MasterDataService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.ListMasterdataPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.ListMasterdata(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}
