variable "location" {
    type = string
    description = "the location of azure resources"
    default = "southeastasia"
}

variable "prefix" {
    type = string
    description = "naming prefix for global uniques"
    default = "azfinops"
}

variable "environment" {
    type = string
    description = "environment name"
    default = "dev"
}