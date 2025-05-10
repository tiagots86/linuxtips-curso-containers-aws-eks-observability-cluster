resource "aws_route53_zone" "private" {
  name = format("%s.local", var.project_name)

  vpc {
    vpc_id = data.aws_ssm_parameter.vpc.value
  }
}