package application

import (
	"encoding/json"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/jwt"
	"gitlab.com/wit-id/test/src/authentication/service"
	serviceEmp "gitlab.com/wit-id/test/src/employee/service"
	"gitlab.com/wit-id/test/src/middleware"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/toolkit/config"
	"gitlab.com/wit-id/test/toolkit/log"
)

func AddRouteAuthentication(s *httpservice.Service, cfg config.KVStore, e *echo.Echo) {
	svc := service.NewAuthenticationService(s.GetDB(), s.GetConnectionString(), cfg)
	svcEmp := serviceEmp.NewEmployeeService(s.GetDB(), s.GetConnectionString(), cfg)
	mddw := middleware.NewEnsureToken(s.GetDB(), s.GetConnectionString(), cfg)

	authApp := e.Group("/auth")
	authApp.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "auth app ok")
	})

	authApp.Use(mddw.ValidateToken)

	authApp.POST("/login", login(svc, svcEmp))
	authApp.POST("/logout", logout(svc))
	authApp.POST("/forgot_password_request", forgotPasswordRequest(svc))
	authApp.POST("/forgot_password_submit/:forgot_password_token", forgotPasswordSubmit(svc))
	authApp.POST("/profile", getProfile(svc), mddw.ValidateUserLogin)
	authApp.POST("/change_password", changeSelfPassword(svc), mddw.ValidateUserLogin)
}

func login(svc *service.AuthenticationService, svcEmp *serviceEmp.EmployeeService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		var request payload.LoginPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		empCheck, errEmpCheck := svcEmp.GetEmployeeByUsername(ctx.Request().Context(), request.Username)
		if errEmpCheck != nil {
			log.FromCtx(ctx.Request().Context()).Error(errEmpCheck, "your account not found, please contact administrator")
			return errors.WithStack(httpservice.ErrHRISEmployeeNotFound)
		}

		// Unmarshal JSON data into struct
		var apiResponseEmployeeCheck payload.EmployeeJson
		errEmpCheck = json.Unmarshal(empCheck, &apiResponseEmployeeCheck)
		if errEmpCheck != nil {
			log.FromCtx(ctx.Request().Context()).Error(errEmpCheck, "failed Unmarshal json employee")
			return errors.WithStack(httpservice.ErrBadRequest)
		}
		emp, errEmp := svcEmp.GetEmployeeIsActiveByUsername(ctx.Request().Context(), request.Username)
		if errEmp != nil {
			log.FromCtx(ctx.Request().Context()).Error(errEmp, "your account not registered in system, please contact administrator")
			return errors.WithStack(httpservice.ErrEmployeeIsNotRegistered)
		}

		// Unmarshal JSON data into struct
		var apiResponseEmployee payload.EmployeeJson
		errEmp = json.Unmarshal([]byte(emp), &apiResponseEmployee)
		if errEmp != nil {
			log.FromCtx(ctx.Request().Context()).Error(errEmp, "failed Unmarshal json employee")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if apiResponseEmployee.GUID == "" {
			log.FromCtx(ctx.Request().Context()).Error(errEmp, "your account not active, please contact administrator")
			return errors.WithStack(httpservice.ErrEmployeeIsNotActive)
		}

		data, err := svc.Login(ctx.Request().Context(), request, ctx.Get("token-data").(jwt.RequestJWTToken), apiResponseEmployee.Email)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, data, nil)
	}
}

func logout(svc *service.AuthenticationService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		// var request payload.LogoutPayload
		// if err := ctx.Bind(&request); err != nil {
		// 	log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
		// 	return errors.WithStack(httpservice.ErrBadRequest)
		// }

		// if err := request.Validate(ctx.Request().Context()); err != nil {
		// 	return err
		// }

		err := svc.LogoutToken(ctx.Request().Context(), ctx.Get("token-data").(jwt.RequestJWTToken))
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, nil, nil)
	}
}

func forgotPasswordRequest(svc *service.AuthenticationService) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		var request payload.ForgotPasswordRequestPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		responseSubject, responseBody, err := svc.ForgotPasswordRequest(ctx.Request().Context(), request.Username)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, payload.ToPayloadForgotPasswordRequest(responseSubject, responseBody), nil)
	}
}

func forgotPasswordSubmit(svc *service.AuthenticationService) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		forgotPasswordToken := ctx.Param("forgot_password_token")
		if forgotPasswordToken == "" {
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		var request payload.ForgotPasswordSubmitPayload
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		if request.Password != request.PasswordConfirmation {
			return httpservice.ErrBadRequest
		}

		err := svc.ForgotPasswordChange(ctx.Request().Context(),
			forgotPasswordToken,
			request.Password)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, true, nil)
	}
}

func getProfile(svc *service.AuthenticationService) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		userInfo := ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData)

		profile, err := svc.GetProfileFromToken(ctx.Request().Context(), userInfo.EmployeeID)
		if err != nil {
			return err
		}

		return httpservice.ResponseData(ctx, profile, nil)
	}
}

func changeSelfPassword(svc *service.AuthenticationService) echo.HandlerFunc {
	return func(ctx echo.Context) error {

		userInfo := ctx.Get(constants.MddwUserBackoffice).(payload.ResponseAuthenticationData)
		profile, err := svc.GetProfileFromToken(ctx.Request().Context(), userInfo.EmployeeID)
		if err != nil {
			return err
		}

		// Unmarshal JSON data into struct
		var apiResponseEmployee payload.EmployeeJson
		err = json.Unmarshal(profile, &apiResponseEmployee)
		if err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		var request payload.ChangePassword
		if err := ctx.Bind(&request); err != nil {
			log.FromCtx(ctx.Request().Context()).Error(err, "failed to parse request")
			return errors.WithStack(httpservice.ErrBadRequest)
		}

		if err := request.Validate(ctx.Request().Context()); err != nil {
			return err
		}

		err = svc.ChangeEmployeePassword(ctx.Request().Context(), apiResponseEmployee.IDCard, request)
		if err != nil {
			return err
		}
		return httpservice.ResponseData(ctx, true, nil)
	}
}
