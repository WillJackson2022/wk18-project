# wk18-project

# NOTE: Use the Terraform documentation to build out your code. You should not be copying and pasting a past or current guest’s code.

# Your team needs you to diagram and deploy a two-tier architecture for your company. For the Foundational project you are allowed to have all your code in a single main.tf file (known as a monolith) with hardcoded data.

# Deploy a VPC with CIDR 10.0.0.0/16 with 2 public subnets with CIDR 10.0.1.0/24 and 10.0.2.0/24. Each public subnet should be in a different AZ for high availability.

# Create 2 private subnet with CIDR '10.0.3.0/24' and '10.0.4.0/24' with an RDS MySQL instance (micro) in one of the subnets. Each private subnet should be in a different AZ.

# Aload balancer that will direct traffic to the public subnets.

# Deploy 1 EC2 t2.micro instance in each public subnet.
