.PHONY: migrate-up migrate-down

migrate-up:
	@migrate -source file://./migrations -database 'mysql://$(DB_USERNAME):$(DB_PASSWORD)@tcp($(DB_HOSTNAME):3306)/$(DB_NAME)' up

migrate-down:
	@migrate -source file://./migrations -database 'mysql://$(DB_USERNAME):$(DB_PASSWORD)@tcp($(DB_HOSTNAME):3306)/$(DB_NAME)' down -all
