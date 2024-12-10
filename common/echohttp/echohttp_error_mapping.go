package echohttp

import "gitlab.com/wit-id/test/common/constants"

var (
	ErrInternalServerErrror = constants.ErrorResponse{
		ID: "Terjadi Kesalahan Pada Server",
		EN: "Internal Server Error",
	}

	ErrBadRequest = constants.ErrorResponse{
		ID: "Payload Permintaan Tidak Sesuai",
		EN: "Bad Request Payload",
	}

	ErrInvalidAppKey = constants.ErrorResponse{
		ID: "APP Key Tidak Sesuai",
		EN: "Invalid APP Key",
	}

	ErrUnknownSource = constants.ErrorResponse{
		ID: "Error Tidak Diketahui",
		EN: "Unknown Error",
	}

	ErrMissingHeaderData = constants.ErrorResponse{
		ID: "Data Header Tidak Ada",
		EN: "Missing Header Data",
	}

	ErrInvalidToken = constants.ErrorResponse{
		ID: "Token Tidak Valid",
		EN: "Invalid Token",
	}

	ErrUserAlreadyCheckIn = constants.ErrorResponse{
		ID: "user sudah check in hari ini",
		EN: "this user is checked in already",
	}

	ErrUserModuleAttemptReachedMax = constants.ErrorResponse{
		ID: "user untuk module attempt ini sudah melampaui batas",
		EN: "user for this module attempt reached max",
	}

	ErrUserModuleAttemptIsTaken = constants.ErrorResponse{
		ID: "user untuk module attempt ini sudah tersimpan di database",
		EN: "user for this module attempt is taken already",
	}

	ErrEditAssesmentWhichAlreadyTaken = constants.ErrorResponse{
		ID: "user tidak dapat mengubah assesment ketika assesment sudah di gunakan",
		EN: "user cant update this assesment while this assesment already taken",
	}

	ErrUnauthorizedTokenData = constants.ErrorResponse{
		ID: "Data Token Tidak Sah",
		EN: "Unauthorized token data",
	}

	ErrInvalidOTP = constants.ErrorResponse{
		ID: "OTP Tidak Valid",
		EN: "Invalid OTP",
	}

	ErrInvalidOTPToken = constants.ErrorResponse{
		ID: "OTP Token Tidak Valid",
		EN: "Invalid OTP Token",
	}

	ErrInvalidPhoneNumberOTP = constants.ErrorResponse{
		ID: "Nomor Telefon Anda Tidak Valid Untuk OTP ini",
		EN: "Your Phone Number Is Invalid For This OTP",
	}

	ErrPasswordNotMatch = constants.ErrorResponse{
		ID: "Kata Sandi Tidak Cocok",
		EN: "Password Not Match",
	}

	ErrConfirmPasswordNotMatch = constants.ErrorResponse{
		ID: "Konfirmasi Kata Sandi Tidak Cocok",
		EN: "Confirm Password Not Match",
	}

	SuccessChangedPassword = constants.ErrorResponse{
		ID: "Kata Sandi Berhasil Diganti",
		EN: "Successfully Changed Password",
	}

	ErrNoResultData = constants.ErrorResponse{
		ID: "Tidak Ada Data Hasil",
		EN: "No Result Data",
	}

	ErrUserAlreadyRegistered = constants.ErrorResponse{
		ID: "Email atau Nomor Telefon Sudah Terdaftar",
		EN: "Email or Phone Number is Already Registered",
	}

	ErrUserNotFound = constants.ErrorResponse{
		ID: "User Tidak Ditemukan",
		EN: "User Not Found",
	}

	ErrUnauthorizedUser = constants.ErrorResponse{
		ID: "User Tidak Sah",
		EN: "Unauthorized User",
	}

	ErrInactiveUser = constants.ErrorResponse{
		ID: "User Tidak Aktif",
		EN: "User not Active",
	}

	ErrRoleNotFound = constants.ErrorResponse{
		ID: "Role Tidak Ditemukan",
		EN: "Role not Found",
	}

	ErrInvalidPromotionCode = constants.ErrorResponse{
		ID: "Kode Promosi Tidak Valid",
		EN: "Invalid Promotion Code",
	}

	ErrInsufficientQuantityVoucher = constants.ErrorResponse{
		ID: "Kuantitas Voucher Tidak Mencukupi",
		EN: "Insufficient Quantities of Voucher",
	}

	ErrVoucherIsNotActive = constants.ErrorResponse{
		ID: "Voucher tidak aktif",
		EN: "Voucher Is not Active",
	}

	ErrVoucherIsExpired = constants.ErrorResponse{
		ID: "Voucher Sudah Kadaluarsa",
		EN: "Voucher is Expired",
	}

	ErrInvalidPaymentID = constants.ErrorResponse{
		ID: "ID Pembayaran Tidak Valid",
		EN: "Invalid Payment ID",
	}

	ErrNIKAlreadyExist = constants.ErrorResponse{
		ID: "Nomor NIK Sudah Terdaftar",
		EN: "NIK Number is Already Registered",
	}

	ErrIDCardAlreadyExist = constants.ErrorResponse{
		ID: "Nomor ID Card Sudah Terdaftar",
		EN: "ID Card Number is Already Registered",
	}

	ErrNPWPAlreadyExist = constants.ErrorResponse{
		ID: "Nomor NPWP Sudah Terdaftar",
		EN: "NPWP Number is Already Registered",
	}

	ErrEmailAlreadyExist = constants.ErrorResponse{
		ID: "Alamat Email Sudah Terdaftar",
		EN: "Email Address is Already Registered",
	}

	ErrPhoneNumberAlreadyExist = constants.ErrorResponse{
		ID: "Nomor Telepon Sudah Terdaftar",
		EN: "Phone Number is Already Registered",
	}

	ErrConstraintViolation = constants.ErrorResponse{
		ID: "Pelanggaran Batasan Unik Saat Menyisipkan atau Memperbarui",
		EN: "Unique Constraint Violation While Insert or Update",
	}

	ErrHrisEmployeeNotFound = constants.ErrorResponse{
		ID: "akun tidak ditemukan, mohon untuk hubungi pihak administrasi",
		EN: "your account not found, please contact administrator",
	}

	ErrEmployeeIsNotActive = constants.ErrorResponse{
		ID: "akun tidak aktif, harap hubungi pihak administrasi",
		EN: "your account not active, please contact administrator",
	}

	ErrEmployeeIsNotRegistered = constants.ErrorResponse{
		ID: "akun belum registrasi di dalam sistem, harap hubungi pihak administrasi",
		EN: "your account not registered in system, please contact administrator",
	}

	ErrIamAccessParamMustBeFilled = constants.ErrorResponse{
		ID: "parameter get role menu has access harus di isi",
		EN: "get role menu has access must be filled",
	}

	ErrIamAccessParamChooseOne = constants.ErrorResponse{
		ID: "parameter get role menu has access harus pilih salah satu",
		EN: "get role menu has access parameter must choose one between role guid or iam access guid",
	}

	ErrSidebarURLNull = constants.ErrorResponse{
		ID: "url must exists if has page",
		EN: "url must exists if has page",
	}

	ErrSidebarURLNotNull = constants.ErrorResponse{
		ID: "url must be null if not has page",
		EN: "url must be null if not has page",
	}

	ErrDepartementUnique = constants.ErrorResponse{
		ID: "kode departement sudah terdaftar",
		EN: "departement code already exists",
	}

	ErrPositionUnique = constants.ErrorResponse{
		ID: "kode jabatan sudah terdaftar",
		EN: "position code already exists",
	}

	ErrRoleUnique = constants.ErrorResponse{
		ID: "kode role sudah terdaftar",
		EN: "role code already exists",
	}

	ErrEmployeeUnique = constants.ErrorResponse{
		ID: "email/employee_id sudah terdaftar",
		EN: "email/employee_id already exists",
	}
)
