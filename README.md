# Doppler Ruby on Rails Sample App (WIP)

Secure and simplified secrets management for Ruby on Rails applications using Doppler and Rails encrypted credentials.

## Prerequisites

- Ruby 2.7
- [Doppler CLI](https://docs.doppler.com/docs/install-cli)

## Setup

Install the Rails dependencies:

```sh
bundle install
```

Setup the Doppler project:

```sh
make setup-project
```

Then spin up a temporary MySQL instance using Docker: 

```sh
docker-mysql-up
```

## Solution Overview

Doppler secrets are bundled into the [Rails custom credentials](https://guides.rubyonrails.org/security.html#custom-credentials) file as part of the deployment process using the `RAILS_MASTER_KEY`  environment variable (also stored in Doppler) for encryption during CI/CD and decryption at runtime.

This approach leverages Rails built-in secrets management APIs but without the manual editing workflow or committing the `credentials.yml.enc` to version control It also works equally well in local and production environments.

In addition to the standard Development, Staging, and Production environments, a custom **Infra** environment with branch configs for staging and production are the source of truth for the `RAILS_MASTER_KEY` value.  Staging and Production reference the `RAILS_MASTER_KEY` while integration syncs for each branch config ensure that the `RAILS_MASTER_KEY` value is always kept in sync between the `credentials.yml.enc`, CI/CD secrets (e.g. GitHub Actions), and the runtime environment (e.g. Heroku Config Vars).

The [Makefile](Makefile) contains the Doppler-specific implementation details. 

Database configuration ([config/database.yml](config/database.yml) ) works by reading values from the `credentials.yml.enc` file using `Rails.application.credentials.dig`. 

> NOTE: A future version of this sample will contain a sample GitHub Action and video showing this workflow end-to-end.

## Usage

### Local Development

Simply auto-generate the `config/credentials.yml.enc` file, then run the server:

```sh
# Used for encryption and decryption
export RAILS_MASTER_KEY="$(doppler secrets get RAILS_MASTER_KEY --plain)"

# Recreate each time so RAILS_MASTER_KEY valued aren't required to match between invocations
rm -f config/credentials.yml.enc

# Inject secrets into credentials.yml.enc
RAILS_MASTER_KEY="$(doppler secrets get RAILS_MASTER_KEY --plain)" EDITOR='doppler secrets download --no-file --format yaml --name-transformer lower-snake | grep -v rails_master_key > ' bin/rails credentials:edit

# Run server
bin/rails server
```

Alternatively, this can be reduced to a single command using `make` or an equivalent shell script:

```shell
make server
```

The [Makefile](Makefile) provides a more compact and reusable form which can be applied to other rails tasks such as database migrations and console usage. 

### Production

Production usage consists of two discreet steps that are presumed to run in different environments:

1. CI: Encryption
2. Runtime: Decryption

Doppler integrations would be set up to sync the `RAILS_MASTER_KEY` to both the CI and the runtime environment.

The the CI environment will also need a [Doppler Service Token](https://docs.doppler.com/docs/service-tokens) exposed as a `DOPPLER_TOKEN` environment variable to provide the Doppler CLI access for fetching secrets.
