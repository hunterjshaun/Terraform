# --- root/main.tf ---

module "networking" {
  source   = "./Networking"
  vpc_cidr = "10.123.0.0/16"
}