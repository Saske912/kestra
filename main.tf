provider "vault" {
}

data "vault_kv_secret_v2" "kubernetes" {
  mount = "kubernetes"
  name  = "data"
}

data "vault_kv_secret_v2" "minio" {
  mount = "minio"
  name  = "data"
}

data "vault_kv_secret_v2" "postgresql" {
  mount = "storage"
  name  = "postgresql"
}

locals {
  k8s      = data.vault_kv_secret_v2.kubernetes.data
  minio    = data.vault_kv_secret_v2.minio.data
  postgres = data.vault_kv_secret_v2.postgresql.data
}

provider "helm" {
  kubernetes {
    host                   = local.k8s["host"]
    cluster_ca_certificate = local.k8s["ca"]
    client_certificate     = local.k8s["cert"]
    client_key             = local.k8s["key"]
  }
}

provider "kubernetes" {
  host                   = local.k8s["host"]
  cluster_ca_certificate = local.k8s["ca"]
  client_certificate     = local.k8s["cert"]
  client_key             = local.k8s["key"]
}

provider "minio" {
  // required
  minio_server   = local.minio["API_HOST"]
  minio_user     = local.minio["ADMIN_USER"]
  minio_password = local.minio["ADMIN_PASSWORD"]

  // optional
  minio_region      = local.minio["REGION"]
  minio_api_version = "v4"
  minio_ssl         = true
}

provider "postgresql" {
  host            = local.postgres["HOST"]
  port            = 5432
  database        = "postgres"
  username        = "postgres"
  password        = local.postgres["INITIAL_ADMIN_PASSWORD"]
  sslmode         = "require"
  connect_timeout = 15
}
