/*****************************************
  Google Provider Configuration
 *****************************************/
provider "google" {
  project = var.project_id
  region  = var.region
  #credentials = "${file("~/sakey.json")}"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

/*****************************************
  Kubernetes provider configuration
 *****************************************/
provider "kubernetes" {
  #version                = "~> 1.10"
  config_context_auth_info = "ops1"
  config_context_cluster   = "apps"
  alias = "app"  
  load_config_file       = false
  host                   = module.anthos-gke.endpoint
  token                  = data.google_client_config.anthos.access_token
  cluster_ca_certificate = base64decode(module.anthos-gke.ca_certificate)
}

provider "kubernetes" {
  config_context_auth_info = "ops1"
  config_context_cluster   = "dbs"
  alias = "db"  
  load_config_file       = false
  host                   = module.anthos-gke-db.endpoint
  token                  = data.google_client_config.anthos.access_token
  cluster_ca_certificate = base64decode(module.anthos-gke-db.ca_certificate)
}

/*****************************************
  Helm provider configuration
 *****************************************/
# module "gke_auth" {
#   source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
#   #version = "~> 9.1"

#   project_id   = data.google_client_config.anthos.project
#   cluster_name = module.anthos-gke.name
#   location     = module.anthos-gke.location
# }

# provider "helm" {
#   kubernetes {
#     //load_config_file       = false
#     config_path            = "~/.kube/config"
#     cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
#     host                   = module.gke_auth.host
#     token                  = module.gke_auth.token
#   }
# }
