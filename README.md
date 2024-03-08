# AWS-Simple-EKS

This repository contains the infrastructure code to set up an Elastic Kubernetes Service (EKS) cluster on AWS using Terraform. The structure is organized to modularize components of the EKS cluster, its related resources, and configurations.

## Structure

- **add-ons/**: This directory holds the configurations for additional features or software to be installed on the EKS cluster, such as monitoring tools, logging, or integrations.
  
- **argo/**: Contains the declarative configuration files for Argo CD, a continuous deployment tool that enables the automated deployment of applications to Kubernetes.
  
- **karpenter/**: Holds the configurations for Karpenter, an open-source auto-scaling project designed for Kubernetes.

- **data.tf**: Terraform file defining data sources that the Terraform configuration may use.

- **databases.tf**: Terraform configuration for setting up databases related to the EKS cluster.

- **dev.tfvars**: Variable definitions for a development environment in Terraform.

- **ebs-csi-policy.json**: A policy document for the Amazon EBS CSI driver that provides a storage interface to attach EBS as persistent volumes in Kubernetes.

- **ecr.tf**: Terraform configuration for the Elastic Container Registry, where Docker images used in the cluster are stored.

- **efs.tf**: Terraform configuration for setting up the Elastic File System, providing shared file storage for the EKS cluster.

- **eks.tf**: Main Terraform configuration file for creating an EKS cluster.

- **main.tf**: The primary entry point for Terraform configurations, often used to define the provider and initialize the backend.

- **provider.tf**: Defines the Terraform provider(s) and their configurations, such as AWS.

- **s3.tf**: Terraform configuration for setting up S3 buckets, potentially for storage related to the EKS operations.

- **storageclass.yml**: A Kubernetes manifest file that defines storage classes which dictate how storage volumes are dynamically provisioned.

- **vars.tf**: Defines the input variables for the Terraform configurations.

- **vpc.tf**: Terraform configuration for setting up the Virtual Private Cloud (VPC) where the EKS cluster will reside.

## Usage

To use this repository, ensure that you have Terraform and AWS CLI installed and configured on your machine. You may need to adjust the variable files to match your specific AWS setup.

Please refer to the individual Terraform files for detailed resource configurations and adapt them to your infrastructure requirements.
