resource "kubernetes_namespace_v1" "kestra" {
  metadata {
    name = "kestra"
  }
}

resource "helm_release" "kestra" {
  repository = "https://helm.kestra.io/"
  chart      = "kestra"
  name       = "kestra"
  namespace  = kubernetes_namespace_v1.kestra.metadata[0].name
  version    = "0.16.0"
  values = [templatefile("${path.module}/ketsraValues.yml", {
    minio = local.minio
    pg    = local.postgresql
  })]
}
