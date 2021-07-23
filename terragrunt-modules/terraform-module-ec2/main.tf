terraform {
  required_version = "~> 0.14.0"
}

# ----------------------------------------------------------------------------------------------------------------------
# EC2
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "main" {
  count = var.instance_count

  ami                  = var.ami
  instance_type        = var.instance_type
  user_data            = var.user_data
  key_name             = var.key_name
  iam_instance_profile = data.aws_iam_instance_profile.being_used.name

  subnet_id = element(distinct(compact(concat(list(var.subnet_id), var.subnet_ids))), count.index)

  private_ip                  = var.private_ip
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = var.vpc_security_group_ids

  monitoring              = var.monitoring
  disable_api_termination = var.disable_api_termination
  source_dest_check       = var.source_dest_check

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  ebs_optimized     = var.ebs_optimized
  
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = merge(
    map("Name", var.instance_count > 1 ? format("%s-%d", var.name, count.index + 1) : var.name),
    var.tags
  )

  volume_tags = merge(
    map("Name", var.instance_count > 1 ? format("%s-%d", var.name, count.index + 1) : var.name),
    var.tags
  )
}

# Select user specified instance profile or the default one created (see below)
data "aws_iam_instance_profile" "being_used" {
  name = var.iam_instance_profile != "" ? var.iam_instance_profile : join("", aws_iam_instance_profile.default.*.id)
}

# ----------------------------------------------------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------------------------------------------------

# Default instance profile, role and policy document if instance profile is not specified
resource "aws_iam_instance_profile" "default" {
  count = var.iam_instance_profile != "" ? 0 : 1

  role = aws_iam_role.default[0].name
}

resource "aws_iam_role" "default" {
  count = var.iam_instance_profile != "" ? 0 : 1

  assume_role_policy = data.aws_iam_policy_document.allow_ec2_to_assume_role.json
}

data "aws_iam_policy_document" "allow_ec2_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# SSM ACCESS
# ----------------------------------------------------------------------------------------------------------------------

# Attaches default Amazon policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count = var.enable_ssm ? 1 : 0

  role       = data.aws_iam_instance_profile.being_used.role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
