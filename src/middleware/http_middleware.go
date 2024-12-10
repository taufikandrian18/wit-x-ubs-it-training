package middleware

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/labstack/echo/v4"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/jwt"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/config"
)

type EnsureToken struct {
	mainDB           *sql.DB
	connectionString string
	config           config.KVStore
}

type AccessPage struct {
	Page    string   `json:"page"`
	KeyPage string   `json:"key_page"`
	Access  []string `json:"access"`
}

func NewEnsureToken(db *sql.DB, connectionString string, cfg config.KVStore) *EnsureToken {
	return &EnsureToken{
		mainDB:           db,
		connectionString: connectionString,
		config:           cfg,
	}
}

func (v *EnsureToken) ValidateToken(next echo.HandlerFunc) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		request := ctx.Request()

		headerDataToken := request.Header.Get(v.config.GetString("header.token-param"))
		if headerDataToken == "" {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderTokenNotFound).SetInternal(errors.Wrap(httpservice.ErrMissingHeaderData, httpservice.MsgHeaderTokenNotFound))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderTokenNotFound))
		}

		jwtResponse, err := jwt.ClaimsJwtToken(ctx.Request().Context(), v.config, headerDataToken)
		if err != nil {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderTokenUnauthorized).SetInternal(errors.Wrap(err, httpservice.MsgHeaderTokenUnauthorized))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderTokenUnauthorized))
		}

		// Set data jwt response to ...
		ctx.Set(constants.MddwTokenKey, jwtResponse)

		return next(ctx)
	}
}

func (v *EnsureToken) ValidateRefreshToken(next echo.HandlerFunc) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		request := ctx.Request()

		headerDataToken := request.Header.Get(v.config.GetString("header.refresh-token-param"))
		if headerDataToken == "" {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderRefreshTokenNotFound).SetInternal(errors.Wrap(httpservice.ErrMissingHeaderData, httpservice.MsgHeaderRefreshTokenNotFound))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderRefreshTokenNotFound))
		}

		jwtResponse, err := jwt.ClaimsJwtToken(ctx.Request().Context(), v.config, headerDataToken)
		if err != nil {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderRefreshTokenUnauthorized).SetInternal(errors.Wrap(err, httpservice.MsgHeaderRefreshTokenUnauthorized))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderRefreshTokenUnauthorized))
		}

		// Set data jwt response to ...
		ctx.Set(constants.MddwTokenKey, jwtResponse)

		return next(ctx)
	}
}

func (v *EnsureToken) ValidateUserLogin(next echo.HandlerFunc) echo.HandlerFunc {
	return func(ctx echo.Context) error {
		// Get data token session
		tokenAuth := ctx.Get(constants.MddwTokenKey).(jwt.RequestJWTToken)

		q := query.New(v.connectionString)

		tokenData, err := q.GetAuthToken(ctx.Request().Context(), query.GetAuthTokenParams{
			TokenAuthName: tokenAuth.AppName,
			DeviceID:      tokenAuth.DeviceID,
			DeviceType:    tokenAuth.DeviceType,
		})
		if err != nil {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgHeaderTokenUnauthorized).SetInternal(errors.Wrap(httpservice.ErrUnauthorizedTokenData, httpservice.MsgHeaderTokenUnauthorized))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.ErrMissingHeaderData))
		}

		// Unmarshal JSON data into struct
		var apiResponse payload.ResponseAuthToken
		err = json.Unmarshal(tokenData, &apiResponse)
		if err != nil {
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.ErrMissingHeaderData))
		}

		if apiResponse.IsLogin == 0 {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgIsNotLogin).SetInternal(errors.WithMessage(httpservice.ErrUnauthorizedUser, httpservice.MsgIsNotLogin))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgIsNotLogin))
		}

		// Get user authentication
		userData, err := q.GetAuthenticationByID(ctx.Request().Context(), apiResponse.UserLogin)
		if err != nil {
			//  return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgUnauthorizedUser).SetInternal(errors.Wrap(httpservice.ErrUnauthorizedUser, httpservice.MsgUnauthorizedUser))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgUnauthorizedUser))
		}

		// Unmarshal JSON data into struct
		var apiResponseAuthentication payload.ResponseAuthenticationData
		err = json.Unmarshal(userData, &apiResponseAuthentication)
		if err != nil {
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.ErrMissingHeaderData))
		}
		// // check active user {
		if strings.ToLower(apiResponseAuthentication.Status) != "active" {
			// return echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgUserNotActive).SetInternal(errors.WithMessage(httpservice.ErrUnauthorizedUser, httpservice.MsgUserNotActive))
			return ctx.JSON(http.StatusUnauthorized, echo.NewHTTPError(http.StatusUnauthorized, httpservice.MsgUserNotActive))
		}

		// Set data user response to ...
		ctx.Set(constants.MddwUserBackoffice, apiResponseAuthentication)

		iamData, _ := v.getIAMAccessToken(ctx.Request().Context(), IAMAccessPayload{
			EmployeeGUID: apiResponseAuthentication.EmployeeID,
		})

		ctx.Set(constants.MddwKeyRole, iamData)
		// Set data IAM
		// filterIAM := IAMAccessPayload{
		// 	JobID:      userData.JobID.String,
		// 	PropertyID: userData.PropertyID.String,
		// 	BrandID:    userData.BrandID.String,
		// 	GroupID:    userData.GroupID.String,
		// }

		// iamData, err := v.getIAMAccessToken(filterIAM)
		// if err == nil {
		// 	if userData.PropertyID.Valid {
		// 		property, errProperty := q.GetProperty(context.Background(), userData.PropertyID.String)
		// 		if errProperty == nil {
		// 			iamData.PropertyID.ID = property.Guid
		// 			iamData.PropertyID.Name = property.Name
		// 		} else {
		// 			log.Println("faield get property", errProperty)
		// 		}

		// 	}

		// 	ctx.Set(constants.MddwKeyRole, iamData)
		// }

		return next(ctx)
	}
}
