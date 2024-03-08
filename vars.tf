variable "cluster-name" {
    type = string
    description = "The name of the K8s cluster to create"
    default = "eks-cluster"
}

variable "env" {
    type = string
    description = "The name of the environment"
    default = "dev"
}

variable "cidr" {
    type = string
    description = "The CIDR for the VPC"
    default = "172.55.0.0/16"
}

variable "vpc-name" {
    type = string
    description = "The name of the VPC"
    default = "eks-cluster"
}

variable "k8s" {
    type = bool
    description = "Whether or not we will be running K8s in this vpc"
    default = true
}

variable "worker-instance-types" {
    type = list
    description = "The types of instances that are allowed in the worker node group"
    default = ["t3.2xlarge"]
}

variable "desired-size" {
    type = string
    description = "The desired number of worker nodes"
    default = 3
}

variable "max-size" {
    type = string
    description = "The maximum number of worker nodes"
    default = 5
}

variable "min-size" {
    type = string
    description = "The minimum number of worker nodes"
    default = 1
}

variable "mysql-dbs" {
    type = map(object({
        service = string,
        engine-version = string,
        database-name = string,
        snapshot-mode = bool,
        snapshot-id = optional(string, null),   
        instance-class = string     
    }))
}
