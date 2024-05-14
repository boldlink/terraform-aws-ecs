/*
locals {
  ecs_instance_userdata = <<USERDATA
#!/bin/bash -x
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=samplecluster2
EOF
USERDATA
}

resource "aws_ecs_cluster" "this" {
  name = "samplecluster2"
}

resource "aws_launch_configuration" "ecs_launch_config" {   
  name_prefix                 = "ECSCluster-launch-configuration"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance.name
  image_id                    = "ami-0069d66985b09d219"
  instance_type               = "t3.micro"
  #security_groups             = [aws_security_group.ecs_instance_sg.id]
  user_data_base64            = base64encode(local.ecs_instance_userdata)
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "30"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "samplecluster2-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name                  = "samplecluster2_ecs_instance_role"
  description           = "IAM Role for ECS Cluster  Nodes"
  force_detach_policies = true

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
*/
