output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}
output "vpc_id" {
  value = "${aws_vpc.nats_network.id}"
}
output "cidr" {
  value = "${aws_vpc.nats_network.cidr_block}"
}

