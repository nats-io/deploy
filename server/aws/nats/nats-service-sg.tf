resource "aws_security_group" "nats_service_custom_group" {
  name        = "nats_streaming"
  description = "Allow NATS Inbound and NATS HttpService for custom NATS Service"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 4233 
    to_port     = 4233
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 8233 
    to_port     = 8233
    protocol    = "tcp"
    cidr_blocks = "${split(",", var.admin_cidr)}"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "nats_service_host_group" {
  name        = "nats_streaming_host"
  description = "Allow SSH & HTTP to hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${split(",", var.admin_cidr)}"
  }
}
