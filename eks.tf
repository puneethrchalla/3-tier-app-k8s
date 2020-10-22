provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

locals {
  cluster_name = "demo-cluster"
}


module "demo-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "demo-cluster"
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa     = true

  cluster_endpoint_private_access = true

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  node_groups = {
    demo = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_type = "t2.small"
      k8s_labels = {
        Environment = "demo"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.demo-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.demo-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}