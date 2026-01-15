## I AM POLICY

## I AM ROLE

## SECURITY GROUP

##EC2

## DNS RECORD

#NULL RESOURCE - ANSIBLE 




resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}-ssm-pm-policy"
  path        = "/"
  description = "${var.component}-${var.env}-ssm-pm-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  ## I AM POLICY

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:us-east-1:950538586636:parameter/roboshop.${var.env}.${var.component}.*"
        }
    ]
})
}

## I AM ROLE

resource "aws_iam_role" "role" {
  name = "${var.component}-${var.env}-ec2-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name =  "${var.component}-${var.env}-ec2-role"
  role = aws_iam_role.role.name
}

## SECURITY GROUP

resource "aws_security_group" "sg" {
  name        =  "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}


##EC2

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ami.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.sg.id]

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "${var.component}-${var.env}"
  
}
}

## DNS Record 
resource "aws_route53" "dns" {
  zone_id  = "Z0636300RV105YFS5DX5"
  name   = "${var.component}-dev"
  type   = "A"
  tt1   =  30
  records  = [aws_instance.instance.private_ip]
}


# Null resource 

resource "null_resource" "ansible" {
  depends_on - [aws_instance.instance, aws_route53_record.dns]
  provisioner "remote-exec" {

    connection {
        type  = "ssh"
        user = "centos"
        password = "DevOps321"
        host = aws_instance.instance.public_ip
    }
    inline = [

      "sudo labauto ansible",
      "ansible-pull -i localhost, -U https://github.com/Imran-code786/roboshop-ansible.git  main.yml -e env=${var.env} -e role_name=${var.compnent}"
    ]
  }

}