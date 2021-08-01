/*****************************************
  Activate Services in Anthos Project
 *****************************************/
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"

  project_id  = data.google_client_config.anthos.project
  disable_services_on_destroy = false
  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "anthos.googleapis.com",
    "cloudtrace.googleapis.com",
    "meshca.googleapis.com",
    "meshtelemetry.googleapis.com",
    "meshconfig.googleapis.com",
    "iamcredentials.googleapis.com",
    "gkeconnect.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "gkehub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}

### Network Resources for Anthos Cluster
resource "google_compute_network" "vpc" {
  name                    = "anthos-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
  depends_on              = [
    module.project-services.project_id,
    google_service_account_key.asm_credentials,
    local_file.cred_asm
    ]  
}
resource "google_compute_subnetwork" "subnet" {
  name          = "apps-subnet"
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.subnet_cidr

  secondary_ip_range {
    range_name    = "pod-cidr-name"
    ip_cidr_range = var.ip_cidr_subnet_pods
  }
  secondary_ip_range {
    range_name    = "service-cidr-name"
    ip_cidr_range = var.ip_cidr_subnet_services
  }  
}

resource "google_compute_subnetwork" "subnet-db" {
  name          = "db-subnet"
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.subnet_cidr_db

  secondary_ip_range {
    range_name    = "pod-cidr-name-db"
    ip_cidr_range = var.ip_cidr_subnet_pods_db
  }
  secondary_ip_range {
    range_name    = "service-cidr-name-db"
    ip_cidr_range = var.ip_cidr_subnet_services_db
  }  
}

data "google_client_config" "anthos" { }
data "google_project" "anthos" {
  project_id = var.project_id
}

resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = "tf-sa-${var.name}"
  display_name = "Cluster Service Account for ${var.name}"
}

resource "google_project_iam_member" "cluster_iam_logginglogwriter" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "cluster_iam_monitoringmetricwriter" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "cluster_iam_monitoringviewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "cluster_iam_artifactregistryreader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

/*****************************************
  Apps GKE Cluster
 *****************************************/
module "anthos-gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster/"
  version                  = "13.0.0"
  project_id               = data.google_client_config.anthos.project
  name                     = var.clusname
  regional                 = true
  region                   = var.region
  zones                    = var.zones
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  ip_range_pods            = var.ip_cidr_subnet_pods
  ip_range_services        = var.ip_cidr_subnet_services
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  create_service_account   = false
  service_account          = google_service_account.service_account.email
  identity_namespace       = "${data.google_client_config.anthos.project}.svc.id.goog"
  node_metadata            = "GKE_METADATA_SERVER"
  cluster_resource_labels  = { "mesh_id" : "proj-${data.google_project.anthos.number}" }
  network_policy             = true
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  release_channel            = "REGULAR"
  node_pools = [
    {
      name               = "apps-anthos-pool"
      ##node_count         = 2
      ##node_locations     = "us-central1-b,us-central1-c"
      min_count          = 2
      max_count          = 3
      preemptible        = true
      machine_type       = "n1-standard-4"
      disk_size_gb       = 50
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true    
      auto_upgrade       = true   
    }
  ]
}

# GKE cluster for hosting DB
module "anthos-gke-db" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster/"
  version                  = "13.0.0"
  project_id               = data.google_client_config.anthos.project
  name                     = var.clusnamedb
  regional                 = true
  region                   = var.region
  zones                    = var.zones
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet-db.name
  ip_range_pods            = var.ip_cidr_subnet_pods_db
  ip_range_services        = var.ip_cidr_subnet_services_db
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  create_service_account   = false
  service_account          = google_service_account.service_account.email
  identity_namespace       = "${data.google_client_config.anthos.project}.svc.id.goog"
  node_metadata            = "GKE_METADATA_SERVER"
  cluster_resource_labels  = { "mesh_id" : "proj-${data.google_project.anthos.number}" }
  network_policy             = true
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  release_channel            = "REGULAR"
  node_pools = [
    {
      name               = "db-anthos-pool"
      ##node_count         = 2
      ##node_locations     = "us-central1-b,us-central1-c"
      min_count          = 2
      max_count          = 3
      preemptible        = true
      machine_type       = "n1-standard-4"
      disk_size_gb       = 50
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true    
      auto_upgrade       = true   
    }
  ]
}

# GH Secrets
# resource "kubernetes_secret" "gh-secrets" {
#   metadata {
#     name = "github-secrets"
#   }
#   data = {
#     github_username = var.github_username
#     github_repo     = var.github_repo
#     github_token    = var.github_token
#   }
# }

#### SA/Key for ASM ####
resource "google_service_account" "asm" {
  account_id   = "anthos-asm-sa"
  display_name = "My Service Account"
}
resource "google_project_iam_member" "asmbind" {
  project = data.google_client_config.anthos.project
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.asm.email}"
}
resource "google_service_account_key" "asm_credentials" {
  service_account_id = google_service_account.asm.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
resource "local_file" "cred_asm" {
  content  = "${base64decode(google_service_account_key.asm_credentials.private_key)}"
  filename = "${path.module}/asm-credentials.json"
}


###  To deploy ASM 
module "asm-anthos" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version          = "15.0.2"
  asm_version      = var.asm_version
  project_id       = data.google_client_config.anthos.project
  cluster_name     = var.clusname
  location         = module.anthos-gke.location
  cluster_endpoint = module.anthos-gke.endpoint
  enable_all            = false
  enable_cluster_roles  = true
  enable_cluster_labels = false
  enable_gcp_apis       = false
  enable_gcp_iam_roles  = false
  enable_gcp_components = true
  enable_registration   = false
  managed_control_plane = false
  service_account       = google_service_account.asm.email
  key_file              = "${path.module}/asm-credentials.json"
  options               = ["envoy-access-log,egressgateways"]
  skip_validation       = true
  outdir                = "./${module.anthos-gke.name}-outdir-${var.asm_version}"
}

resource "time_sleep" "wait_20s" {
  depends_on = [module.anthos-gke]
  create_duration = "20s"
}

resource "google_gke_hub_membership" "membership" {
  depends_on    = [
    time_sleep.wait_20s,
    module.anthos-gke
    ]
  membership_id = "anthos-gke"
  project       = var.project_id
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/projects/${var.project_id}/locations/${var.region}/clusters/${var.clusname}"
    }
  }
  description = "Anthos Cluster Hub Registration"
  provider = google-beta
}


module "asm-anthos-db" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version          = "15.0.2"
  asm_version      = var.asm_version
  project_id       = data.google_client_config.anthos.project
  cluster_name     = var.clusnamedb
  location         = module.anthos-gke-db.location
  cluster_endpoint = module.anthos-gke-db.endpoint
  enable_all            = false
  enable_cluster_roles  = true
  enable_cluster_labels = false
  enable_gcp_apis       = false
  enable_gcp_iam_roles  = false
  enable_gcp_components = true
  enable_registration   = false
  managed_control_plane = false
  service_account       = google_service_account.asm.email
  key_file              = "${path.module}/asm-credentials.json"
  options               = ["envoy-access-log,egressgateways"]
  skip_validation       = true
  outdir                = "./${module.anthos-gke-db.name}-outdir-${var.asm_version}"
}

resource "time_sleep" "wait_20s-db" {
  depends_on = [module.anthos-gke-db]
  create_duration = "20s"
}

resource "google_gke_hub_membership" "membership-db" {
  depends_on    = [
    time_sleep.wait_20s-db,
    module.anthos-gke-db
    ]
  membership_id = "anthos-gke-db"
  project       = var.project_id
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/projects/${var.project_id}/locations/${var.region}/clusters/${var.clusnamedb}"
    }
  }
  description = "Anthos Cluster Hub Registration"
  provider = google-beta
}


# resource "google_gke_hub_feature" "feature" {
#   name = "configmanagement"
#   location = "global"

#   labels = {
#     foo = "bar"
#   }
#   provider = google-beta
# }

# resource "google_gke_hub_feature_membership" "feature_member" {
#   location = "global"
#   feature = google_gke_hub_feature.feature.name
#   membership = google_gke_hub_membership.membership.membership_id
#   configmanagement {
#     version = "1.6.2"
#     config_sync {
#       git {
#         sync_repo = "https://github.com/hashicorp/terraform"
#       }
#     }
#   }
#   provider = google-beta
# }


###  To deploy ACM  
# module "acm-anthos" {
#   source           = "./modules/acm"
#   project_id       = data.google_client_config.anthos.project
#   cluster_name     = var.clusname
#   location         = module.anthos-gke.location
#   cluster_endpoint = module.anthos-gke.endpoint
#   #service_account_key_file = "${path.module}/asm-credentials.json"
#   operator_path    = "config-management-operator.yaml"
#   sync_repo        = var.acm_repo_location
#   sync_branch      = var.acm_branch
#   policy_dir       = var.acm_dir
# }
