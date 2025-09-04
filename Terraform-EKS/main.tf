#VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "EKS_CLUSTER_VPC"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets


  enable_dns_hostnames    = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/Ash-eks-cluster" = "shated"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/Ash-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                = 1

  }
  private_subnet_tags = {
    "kubernetes.io/cluster/Ash-eks-cluster" = "shared"
    "kubernetes.io/role/private_elb"        = 1

  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                   = "Ash-eks-cluster"
  kubernetes_version     = "1.33"
  endpoint_public_access = true
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}