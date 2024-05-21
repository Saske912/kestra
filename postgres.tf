resource "random_password" "kestra" {
  length  = 16
  special = false
}

resource "postgresql_role" "kestra" {
  name     = "kestra"
  login    = true
  password = random_password.kestra.result
}

resource "postgresql_database" "kestra" {
  name  = "kestra"
  owner = postgresql_role.kestra.name
}

locals {
  postgresql = {
    database = postgresql_database.kestra.name
    username = postgresql_role.kestra.name
    password = random_password.kestra.result
    host     = local.postgres["IMPLICIT_HOST"]
    port     = local.postgres["PORT"]
  }
}

resource "vault_kv_secret_v2" "kestra" {
  name  = "kestra"
  mount = "api_providers"
  data_json = ({
    postgres = local.postgres
    minio    = local.minio
  })
}
