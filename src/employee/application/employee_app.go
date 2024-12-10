package application

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/src/employee/service"
	"gitlab.com/wit-id/test/src/middleware"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteEmployee(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewEmployeeService(s.GetDB(), s.GetConnectionString(), cfg)

	mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)

	employeeApp := e.Group("/employee")
	employeeApp.Use(mddw.ValidateToken)
	employeeApp.Use(mddw.ValidateUserLogin)
	employeeApp.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "employee app ok")
	})

	employeeApp.POST("", createEmployee(svc))
	employeeApp.POST("/list", listEmployee(svc))
	employeeApp.PUT("/upload_photo_profile_employee/:guid", uploadHandler(svc))
	employeeApp.PUT("/:guid", updateEmployee(svc))
	employeeApp.GET("/detail/:guid", getEmployeeByGuid(svc))
	employeeApp.DELETE("/:guid", deleteEmployeeByGuid(svc))
}

func createEmployee(svc *service.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.InsertEmployeePayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		emp, err := svc.CreateEmployee(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, emp, nil)
	}
}

func updateEmployee(svc *service.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		var request payload.UpdateEmployeePayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		emp, err := svc.UpdateEmployee(ctx.Request().Context(), request.ToEntity(guid))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, emp, nil)
	}
}

func getEmployeeByGuid(svc *service.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		emp, err := svc.GetEmployee(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, emp, nil)
	}
}

func deleteEmployeeByGuid(svc *service.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		err := svc.DeleteEmployee(ctx.Request().Context(), guid)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, nil, nil)
	}
}

func listEmployee(svc *service.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.ListEmployeePayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		emp, err := svc.GetListEmployee(ctx.Request().Context(), request.ToEntity())
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, emp, nil)
	}
}

func uploadHandler(svc *service.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		// Menerima file dari request
		guid := ctx.Param("guid")
		if guid == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		var request payload.UpdateProfilePayload

		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		emp, err := svc.UpdateProfilePhotoEmployee(ctx.Request().Context(), query.UpdateEmployeeProfilePhotoParams{
			Guid: guid,
			Url:  request.PathUrl,
		})
		if err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "fail update data profile")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		return httpservice.ResponseData(ctx, emp, nil)
	}
}
