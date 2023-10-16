locals {
  cluster_name = "${var.env}-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.vpc_name

  cidr = var.cidr
  azs  = var.aws_availability_zones

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

    public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

  resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
    content  = tls_private_key.ssh_key.private_key_pem
    filename = "${var.path}/bastion_key.pem"
    file_permission = "0600"
}

resource "aws_key_pair" "public_key" {
  key_name   = "public_bastion_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  name = "Bastion-instance"
  instance_type = "t3.small"
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data = <<EOF
  #!/bin/bash

  # Install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  aws --version

  # Install Helm v3
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  helm version

  # Install kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  kubectl version --client

  # Install aws-iam-authenticator
  curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
  chmod +x ./aws-iam-authenticator
  mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
  aws-iam-authenticator help

  # Update Kubectl
  aws eks update-kubeconfig --name ${local.cluster_name}"
EOF
  key_name = aws_key_pair.public_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  iam_instance_profile = aws_iam_instance_profile.this.id
}

resource "aws_iam_instance_profile" "this" {
    name = "instance_profile"
    role = aws_iam_role.role.id 
}

resource "aws_iam_role" "role" {
  name               = "testrole"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
     {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:sts::803253357612:assumed-role/testrole/i-0eb1ff0fbaf51f846"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "web_iam_role_policy"
  role = "${aws_iam_role.role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["eks:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

output "ip" {
  value = data.http.ip.response_body
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = ["${module.ec2-instance.public_ip}/32", "${data.http.ip.response_body}/32"]

  eks_managed_node_group_defaults = {
    ami_type = var.ami_type

  }
  
  manage_aws_auth_configmap = true
  # create_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.role.arn
      username = "testrole"
      groups = [
        "system:bootstrappers",
        "system:nodes",
        "system:masters"
      ]
    }
  ]

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
    }
    ## Enable access from bastion host to Nodes
    ingress_bastion = {
      description       = "Allow access from Bastion Host"
      type              = "ingress"
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      source_security_group_id = aws_security_group.ssh.id
}
  }
## Enable access from bastion host to EKS endpoint
    cluster_security_group_additional_rules = {
        ingress_bastion = {
          description       = "Allow access from Bastion Host"
          type              = "ingress"
          from_port         = 443
          to_port           = 443
          protocol          = "tcp"
          source_security_group_id = aws_security_group.ssh.id
    }
      }

  eks_managed_node_groups = {
    on_demand_1 = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type = "ON_DEMAND"
    }
  }
}

#############
# module "eks_auth" {
#   source = "aidanmelen/eks-auth/aws"
#   eks    = module.eks

#   map_roles = [
#     {
#       rolearn  = aws_iam_role.role.arn
#       username = "testrole"
#       groups = [
#         "system:masters"
#       ]
#     },
#   ]
# }

