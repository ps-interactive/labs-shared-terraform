data "aws_ami" "ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_cloudinit_config" "config" {
  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      package_upgrade: true
      packages:
        - awslogs
        - httpd
      write_files:
        - path: /etc/awslogs/awslogs.conf
          content: |
            [general]
            state_file = /var/lib/awslogs/agent-state

            [access_log]
            file = /var/log/httpd/access_log
            log_group_name = /var/log/httpd/access_log
            log_stream_name = {instance_id}
            datetime_format = %d/%b/%Y:%H:%M:%S
        - path: /var/www/html/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>EC2 HTTPd Server</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>EC2 HTTPd Server</h1>
              </body>
            </html>
        - path: /var/www/html/home/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>Home</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>Home</h1>
              </body>
            </html>
        - path: /var/www/html/page/1/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>Page 1</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>Page 1</h1>
              </body>
            </html>
        - path: /var/www/html/page/2/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>Page 2</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>Page 2</h1>
              </body>
            </html>
        - path: /var/www/html/page/3/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>Page 3</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>Page 3</h1>
              </body>
            </html>
        - path: /var/www/html/page/5/index.html
          content: |
            <!DOCTYPE html>
            <html>
              <head>
                <title>Page 5</title>
                <meta charset="utf-8" />
              </head>
              <body>
                <h1>Page 5</h1>
              </body>
            </html>
      runcmd:
        - sed -ie 's/us-east-1/${data.aws_region.current.name}/' /etc/awslogs/awscli.conf
        - systemctl enable --now httpd
        - systemctl enable --now awslogsd
    EOF
  }
}

resource "aws_instance" "instance" {
  ami                  = data.aws_ami.ami.image_id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.iam.name
  user_data_base64     = data.template_cloudinit_config.config.rendered
}

data "aws_vpc" "default" { default = true }
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_security_group_rule" "http" {
  security_group_id = data.aws_security_group.default.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 80
  to_port           = 80
}
