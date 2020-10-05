resource "aws_route53_zone" "globomantics" {
    name = "prod.globomantics.com"
    vpc {
        vpc_id = data.aws_vpc.default.id
    }
}

resource "aws_route53_record" "primary-ns" {
    zone_id = aws_route53_zone.globomantics.zone_id
    name = "ns1"
    type = "A"
    ttl = 300
    records = ["172.31.0.53"]
}

resource "aws_route53_record" "secondary-ns" {
    zone_id = aws_route53_zone.globomantics.zone_id
    name = "ns2"
    type = "A"
    ttl = 300
    records = ["172.31.16.53"]
}
