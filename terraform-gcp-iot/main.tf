terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

module "iam" {
  source = "./modules/iam"

  project_id = var.project_id
}

module "vpc" {
  source = "./modules/vpc"

  region = var.region
}

module "database" {
  source = "./modules/database"

  machine_type = var.postgres_vm_machine_type
  zone         = var.zone
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.subnet_id
  vpc_name     = module.vpc.vpc_name
  subnet_cidr  = module.vpc.subnet_cidr
  db_user      = var.db_user
  db_password  = var.db_password
  db_name      = var.db_name

  depends_on = [module.vpc]
}

module "api" {
  source = "./modules/api"

  machine_type             = var.api_vm_machine_type
  zone                     = var.zone
  vpc_id                   = module.vpc.vpc_id
  subnet_id                = module.vpc.subnet_id
  vpc_name                 = module.vpc.vpc_name
  service_account_email    = module.iam.service_account_email
  db_private_ip            = module.database.db_private_ip
  db_user                  = var.db_user
  db_password              = var.db_password
  db_name                  = var.db_name
  artifact_registry_region = var.artifact_registry_region
  api_container_image      = var.api_container_image
  iot_api_key              = var.iot_api_key
  grafana_api_key          = var.grafana_api_key
  run_db_init              = var.run_db_init

  depends_on = [module.database]
}

module "grafana" {
  source = "./modules/grafana"

  machine_type          = var.grafana_vm_machine_type
  zone                  = var.zone
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.subnet_id
  vpc_name              = module.vpc.vpc_name
  service_account_email = module.iam.service_account_email
  db_private_ip         = module.database.db_private_ip
  db_user               = var.db_user
  db_password           = var.db_password
  db_name               = var.db_name
  grafana_admin_password = var.grafana_admin_password
  smtp_user = var.smtp_user
  smtp_password = var.smtp_password

  depends_on = [module.database]
}

module "load_balancer" {
  source = "./modules/load_balancer"

  zone                = var.zone
  api_vm_self_link    = module.api.api_vm_self_link
  grafana_vm_self_link = module.grafana.grafana_vm_self_link
  api_domain          = var.api_domain
  grafana_domain      = var.grafana_domain

  depends_on = [module.api, module.grafana]
}