data "aws_route53_zone" "xincto" {
  name         = "aws.xincto.me."
  private_zone = false
}

resource "aws_route53_record" "drupal" {
  zone_id = "${data.aws_route53_zone.xincto.zone_id}"
  name    = "${var.app}-${var.env}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_elastic_beanstalk_environment.eb-env.cname}."]
}
