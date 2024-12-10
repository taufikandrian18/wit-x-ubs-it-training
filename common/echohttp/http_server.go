package echohttp

import (
	"context"
	"net/http"

	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/echokit"

	tokenApp "gitlab.com/wit-id/test/src/auth_token/application"
	authApp "gitlab.com/wit-id/test/src/authentication/application"
	employeeApp "gitlab.com/wit-id/test/src/employee/application"
	IamAccessApp "gitlab.com/wit-id/test/src/iamaccess/application"
	IamHasAccessApp "gitlab.com/wit-id/test/src/iamhasaccess/application"
	masterdataApp "gitlab.com/wit-id/test/src/masterdata/application"
	roleApp "gitlab.com/wit-id/test/src/role/application"
	sidebarApp "gitlab.com/wit-id/test/src/sidebarmenu/application"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func RunEchoHTTPService(ctx context.Context, s *httpservice.Service, cfg config.KVStore) {
	e := echo.New()
	e.HTTPErrorHandler = handleEchoError(cfg)
	e.Use(handleLanguage)

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins:     []string{"*"},
		AllowCredentials: true,
		AllowMethods:     []string{http.MethodGet, http.MethodHead, http.MethodPut, http.MethodPatch, http.MethodPost, http.MethodDelete, http.MethodOptions},
		AllowHeaders:     []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, constants.DefaultAllowHeaderToken, constants.DefaultAllowHeaderRefreshToken, constants.DefaultAllowHeaderAuthorization},
	}))

	runtimeCfg := echokit.NewRuntimeConfig(cfg, "restapi")
	runtimeCfg.HealthCheckFunc = s.GetServiceHealth

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "ok")
	})
	employeeApp.AddRouteEmployee(s, cfg, e)
	sidebarApp.AddRouteSidebarMenu(s, cfg, e)
	masterdataApp.AddRouteMasterdata(s, cfg, e)
	IamAccessApp.AddRouteIamAccess(s, cfg, e)
	IamHasAccessApp.AddRouteIamHasAccess(s, cfg, e)
	tokenApp.AddRouteAuthToken(s, cfg, e)
	authApp.AddRouteAuthentication(s, cfg, e)
	roleApp.AddRouteRole(s, cfg, e)
	// set route config
	httpservice.SetRouteConfig(ctx, s, cfg, e)

	// run actual server
	echokit.RunServerWithContext(ctx, e, runtimeCfg)
}
