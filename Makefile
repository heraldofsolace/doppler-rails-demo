SHELL := /usr/bin/env bash
RAILS_MASTER_KEY=$$(doppler secrets get RAILS_MASTER_KEY --plain)
.PHONY: sync-secrets view-secrets server db-create db-migrate db-rollback console generate docker-mysql-up docker-mysql-down

setup-doppler-project:
	@doppler import --silent
	@doppler setup --no-interactive --silent
	@doppler secrets set RAILS_MASTER_KEY='$${infra_dev.RAILS_MASTER_KEY}' --config dev --silent
	@doppler secrets set RAILS_MASTER_KEY='$${infra_stg.RAILS_MASTER_KEY}' --config stg --silent
	@doppler secrets set RAILS_MASTER_KEY='$${infra_prd.RAILS_MASTER_KEY}' --config prd --silent
	@doppler secrets delete API_KEY DATABASE_HOST DATABASE_NAME DATABASE_PASSWORD DATABASE_PORT DATABASE_USERNAME RAILS_MASTER_KEY SECRET_KEY_BASE --config infra -y --silent

sync-secrets:
	@-rm -f config/credentials.yml.enc
	@RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) EDITOR='doppler secrets download --no-file --format yaml --name-transformer lower-snake | grep -v rails_master_key > ' bin/rails credentials:edit

view-secrets: sync-secrets
	@RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rails credentials:show

server: sync-secrets
	 @RAILS_ENV=development RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rails server

db-create: sync-secrets
	 @RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rake db:create

db-migrate: sync-secrets
	@RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rake db:migrate

db-rollback: sync-secrets
	@RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rake db:rollback

console: sync-secrets
	@RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rails console

generate:
	@RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) bin/rails generate $(RUN_ARGS)

docker-mysql-up:
	docker run --name mysql -d \
		-e MARIADB_DATABASE=$$(doppler secrets get DATABASE_NAME --plain) \
		-e MARIADB_USER=$$(doppler secrets get DATABASE_USERNAME --plain) \
		-e MARIADB_PASSWORD=$$(doppler secrets get DATABASE_PASSWORD --plain) \
		-e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes \
		-p 3306:3306 \
		mariadb:10

docker-mysql-down:
	-docker stop mysql
	-docker rm mysql
