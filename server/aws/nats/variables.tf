variable "region" {
  description = "The AWS region."
}
variable "key_name" {
  description = "The AWS key pair to use for resources."
}
variable "admin_cidr" {
  description = "public ranges IP for admin."
#  default = "0.0.0.0/0"
}
variable "ami" {
  type = "map"
  default = {}
  description = "A map of AMIs"
}
variable "prevent_destroy_nats_data" {
  default = false
}
variable "instance_type" {
  default = "t2.micro"
}
variable "avail_zone" {
  default = ["us-east-1a", "us-east-1b"]
}
variable "instance_ips" { 
     default = {
       "0" = "10.0.1.20"
       "1" = "10.0.1.21"
     }
}
