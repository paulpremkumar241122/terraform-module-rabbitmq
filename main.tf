resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id

  ingress {
    #description      = "SSH"
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = var.sg_subnets_cidr
  }

  ingress {
    #description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.allow_ssh_cidr
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

resource "aws_instance" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.sg.id ]
  subnet_id = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  tags = merge({ Name = "${var.component}-${var.env}" }, var.tags)

  user_data     = templatefile("${path.module}/userdata.sh", {
    environment = var.env
  })
}

