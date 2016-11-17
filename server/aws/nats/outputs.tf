output "elb_dns" {
  value = "${aws_elb.nats.dns_name}"
}
output "addresses" {
  value = ["${aws_launch_configuration.nats_instance.*.public_ip}"]
}
output "public_subnet_id" {
  value = "${module.vpc.public_subnet_id}"
}
