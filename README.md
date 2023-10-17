# Private-EKS-With-Bastion-Host
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.21.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2-instance"></a> [ec2-instance](#module\_ec2-instance) | terraform-aws-modules/ec2-instance/aws | 5.5.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.16.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_key_pair.public_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [external_external.current_ipv4](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | Ami Type for Ec2 instances created in Cluster | `string` | `"AL2_x86_64"` | no |
| <a name="input_aws_availability_zones"></a> [aws\_availability\_zones](#input\_aws\_availability\_zones) | AWS availability zones | `list` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Set this variable if you use another profile besides the default awscli profile called 'default'. | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Set this variable if you use another aws region. | `string` | `"us-east-1"` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | Cird block for your VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | kubernetes cluster version | `string` | `"1.27"` | no |
| <a name="input_env"></a> [env](#input\_env) | it would be a prefix for you cluster name created, typically specified as dev or test | `string` | `"dev"` | no |
| <a name="input_path"></a> [path](#input\_path) | Full path to you ssh folder | `string` | `"ssh"` | no |
| <a name="input_private_key_name"></a> [private\_key\_name](#input\_private\_key\_name) | Full path to you ssh folder | `string` | `"bastion_key.pem"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | private subnets to create, need to have 1 for each AZ | `list` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | public subnets to create, need to have 1 for each AZ | `list` | <pre>[<br>  "10.0.4.0/24",<br>  "10.0.5.0/24",<br>  "10.0.6.0/24"<br>]</pre> | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Vpc name that would be created for your cluster | `string` | `"EKS_vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Connect_to_instance"></a> [Connect\_to\_instance](#output\_Connect\_to\_instance) | The public IP address assigned to the instance |
| <a name="output_EC2_public_ip"></a> [EC2\_public\_ip](#output\_EC2\_public\_ip) | The public IP address assigned to the instance |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the Cluster created |
| <a name="output_current_ipv4_json"></a> [current\_ipv4\_json](#output\_current\_ipv4\_json) | n/a |
| <a name="output_jhfhjf"></a> [jhfhjf](#output\_jhfhjf) | The public IP address assigned to the instance |
<!-- END_TF_DOCS -->