variable "name" {
  description = "The name of the VPC."
}
variable "cidr" {
  description = "The CIDR of the VPC."
}
variable "public_subnet" {
  description = "The public subnet to create."
}
variable "enable_dns_hostnames" {
  description = "Should be true if you want to use private DNS within the VPC"
  default = true
}
variable "enable_dns_support" {
  description = "Should be true if you want to use private DNS within the VPC"
  default = true
}
variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}
