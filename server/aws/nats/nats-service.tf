provider "aws" {
  region = "${var.region}"
}
module "vpc" {
  source        = "./vpc"
  name          = "nats_network"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
}

data "template_file" "config" {
  template = "${file("${path.module}/files/bootstrap.sh")}"

  vars {
    efs_mount_target_ip = "${aws_efs_mount_target.nats-service-efs.ip_address}"
  }
}

resource "aws_elb" "nats" {
  name = "nats-elb"

  # The same availability zone as our instance
  # availability_zones = ["${module.vpc..web.availability_zone}"]
  subnets = ["${module.vpc.public_subnet_id}"]
  security_groups    = ["${aws_security_group.nats_service_custom_group.id}"]

  listener {
    instance_port     = 4233
    instance_protocol = "tcp"
    lb_port           = 4233
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 8233
    instance_protocol = "tcp"
    lb_port           = 8233
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:4233"
    interval            = 30
  }


  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_autoscaling_group" "nats_service" {
  lifecycle { create_before_destroy = true }

  force_delete = true

  # spread the app instances across the availability zones
  # availability_zones = ["${split(",", var.availability_zones)}"]

  # interpolate the LC into the ASG name so it always forces an update
  name = "asg-app - ${aws_launch_configuration.nats_instance.name}"
  max_size = 1
  min_size = 1
  # wait_for_elb_capacity = 1
  desired_capacity = 1 
  health_check_grace_period = 300
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.nats_instance.id}"
  load_balancers = ["${aws_elb.nats.id}"]
  vpc_zone_identifier = ["${module.vpc.public_subnet_id}"]
}

resource "aws_launch_configuration" "nats_instance" {
  image_id = "${lookup(var.ami, var.region)}" 
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  associate_public_ip_address=true
  user_data = "${data.template_file.config.rendered}"

  security_groups = [ 
    "${aws_security_group.nats_service_host_group.id}",
    "${aws_security_group.nats_service_custom_group.id}",
    "${aws_security_group.ec2.id}",
  ]
  lifecycle {
    create_before_destroy = true
  }
  count = 1
}
