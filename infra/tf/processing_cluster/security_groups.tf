resource "aws_security_group" "processing_sg" {
  name        = "processing-sg"
  description = "Traffic from processing"
  vpc_id      = var.vpc_id
  tags = {
    Name = "processing-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "processing_xray" {
  name        = "processing-xray-ingress"
  description = "Allow host to send XRay traces to itself"
  vpc_id      = var.vpc_id
  tags = {
    Name = "processing-xray-ingress"
  }

  ingress {
    from_port       = 40000
    to_port         = 40000
    protocol        = "udp"
    security_groups = [aws_security_group.processing_sg.id]
  }
  ingress {
    from_port       = 40000
    to_port         = 40000
    protocol        = "tcp"
    security_groups = [aws_security_group.processing_sg.id]
  }
}
