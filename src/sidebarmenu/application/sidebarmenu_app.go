package application

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"

	"gitlab.com/wit-id/test/src/middleware"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/sidebarmenu/service"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteSidebarMenu(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewSidebarMenuService(s.GetDB(), s.GetConnectionString(), cfg)
	mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)
	menus := e.Group("/menu")
	menus.Use(mddw.ValidateToken)
	menus.Use(mddw.ValidateUserLogin)
	menus.GET("", func(c echo.Context) error {
		return c.String(http.StatusOK, "menu service ok")
	})

	menus.POST("", createMenu(svc, cfg))
	menus.PUT("/:guid", updateMenu(svc, cfg))
	menus.DELETE("/:guid", deleteMenu(svc, cfg))
	menus.GET("/:guid", getMenu(svc, cfg))
	menus.POST("/list", listMenu(svc, cfg))
	menus.GET("/list", listMenuTree(svc, cfg))

}

func createMenu(svc *service.SidebarMenuService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.CreateSidebarMenuPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.InsertSidebarmenu(ctx.Request().Context(), request.ToEntity(ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func updateMenu(svc *service.SidebarMenuService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.UpdateSidebarMenuPayload
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

		data, err := svc.UpdateSidebarMenu(ctx.Request().Context(), request.ToEntity(guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func deleteMenu(svc *service.SidebarMenuService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		err := svc.DeleteSidebarMenu(ctx.Request().Context(), guid, ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData).GUID)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}

func getMenu(svc *service.SidebarMenuService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		resp, err := svc.GetSidebarMenu(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, resp, nil)
	}
}

func listMenu(svc *service.SidebarMenuService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.ListSidebarMenuPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		data, err := svc.ListSidebarMenu(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func listMenuTree(svc *service.SidebarMenuService, cfg config.KVStore) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		data, err := svc.ListMenuTree(ctx.Request().Context())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}
