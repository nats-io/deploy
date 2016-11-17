resource "aws_efs_file_system" "nats-service-efs" {
  creation_token = "nats-service"
  lifecycle {
    prevent_destroy = true
  }
  tags {
    Name = "NatsServiceEFS"
  }
}

resource "aws_efs_mount_target" "nats-service-efs" {
  file_system_id = "${aws_efs_file_system.nats-service-efs.id}"
  subnet_id      = "${module.vpc.public_subnet_id}"
  security_groups = ["${aws_security_group.mnt.id}"]
}

resource "aws_security_group" "ec2" {
  name        = "nats-service-efs-ec2"
  description = "Allow traffic out to NFS for nats-service-efs-mnt."
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name = "allow_nfs_out_to_efs-mnt"
    terraform = "true"
  }
}

resource "aws_security_group_rule" "nfs-out" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  source_security_group_id = "${aws_security_group.mnt.id}"
}

resource "aws_security_group" "mnt" {
  name        = "nats-service-efs-mnt"
  description = "Allow traffic from instances using nats-service-efs-ec2."
  vpc_id      = "${module.vpc.vpc_id}"
  
  tags {
    Name = "allow_nfs_in_from_nats-servic-efs-ec2"
    terraform = "true"
  }
}

resource "aws_security_group_rule" "nfs-in" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id = "${aws_security_group.mnt.id}"
  source_security_group_id = "${aws_security_group.ec2.id}"
}
