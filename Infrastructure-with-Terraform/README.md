# AWS VPC and EC2 Infrastructure

This Terraform configuration creates a complete AWS VPC infrastructure with public and private subnets, EC2 instances for web and database servers, and all necessary networking components.

## Prerequisites

- Terraform installed
- AWS CLI configured with appropriate credentials
- SSH key pair created in AWS

## Infrastructure Components

- VPC with CIDR block 10.0.0.0/16
- Public subnet in AZ 'a' (10.0.1.0/24)
- Private subnet in AZ 'b' (10.0.2.0/24)
- Internet Gateway
- NAT Gateway
- Route tables for public and private subnets
- Security groups for web and database servers
- EC2 instances:
  - Web server in public subnet
  - Database server in private subnet

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. To destroy the infrastructure:
   ```bash
   terraform destroy
   ```

## Variables

Update `terraform.tfvars` or provide values when running Terraform:

- `aws_region`: AWS region (default: us-west-2)
- `key_name`: Name of your SSH key pair
- `project_name`: Project name for resource tagging
- `ami_id`: AMI ID for EC2 instances
- `instance_type`: EC2 instance type
- `ssh_allowed_cidr`: CIDR block for SSH access

## Outputs

- `vpc_id`: ID of the created VPC
- `web_instance_public_ip`: Public IP of the web server
- `db_instance_private_ip`: Private IP of the database server

## Security Notes

- The default SSH CIDR (0.0.0.0/0) allows access from anywhere. Restrict this in production.
- Update the AMI ID according to your region and requirements.
- Consider encrypting sensitive data and using AWS Secrets Manager for database credentials.
