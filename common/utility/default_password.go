package utility

import (
	"encoding/base64"
	"fmt"
	"math/rand"
	"time"

	"golang.org/x/crypto/scrypt"
)

func GenerateDefaultPassword(empDateOfBirth string) string {

	// Parse the string into a time.Time value
	forgotPasswordExpiry, _ := time.Parse("02-Jan-06 03.04.05.000000000 PM", empDateOfBirth)

	return fmt.Sprint(
		forgotPasswordExpiry.Format("02012006"),
	)
}

func GenerateSalt() string {
	salt := make([]byte, 16)
	rand.Read(salt)
	return base64.URLEncoding.EncodeToString(salt)
}

func HashPassword(password, salt string) string {
	saltedPassword := []byte(password + salt)
	hashedPassword, _ := scrypt.Key(saltedPassword, []byte(salt), 16384, 8, 1, 32)
	return base64.URLEncoding.EncodeToString(hashedPassword)
}
