data "aws_ami" "ami" {
  owners      = ["950538586636"]
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
}