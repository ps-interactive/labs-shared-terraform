resource "aws_launch_template" "web_server" {
  name = "web_server"

  image_id = data.aws_ami.amazon_linux_v2.id

  instance_type = "t2.micro"

  key_name = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-server-asg"
    }
  }

}