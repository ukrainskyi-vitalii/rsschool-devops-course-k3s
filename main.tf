module "vpc" {
  source = "./modules/vpc"
}

module "k3s" {
  source = "./modules/k3s"

  ami_id              = var.ami_id
  vpc_id              = module.vpc.main_vpc_id
  vpc_cidr            = module.vpc.main_vpc_cidr
  ssh_key_name        = var.ssh_key_name
  public_subnet_id    = module.vpc.public_subnet_1_id
}
