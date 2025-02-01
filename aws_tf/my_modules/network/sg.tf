////////////////////// resource //////////////////////
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.sprint_vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

//resource "aws_security_group" "web_sg" {
//  name   = "web-sg"
//  vpc_id = aws_vpc.sprint_vpc.id

//  ingress {
//    from_port   = 80
//    to_port     = 80
//    protocol    = "tcp"
//    security_groups = [aws_security_group.alb_sg.id]
//  }

//  ingress {
//    from_port   = 22
//    to_port     = 22
//    protocol    = "tcp"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}

//output "web_security_group_id" {
//  value = aws_security_group.web_sg.id
//}

resource "aws_security_group" "api_sg" {
  name   = "api-sg"
  vpc_id = aws_vpc.sprint_vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "api_security_group_id" {
  value = aws_security_group.api_sg.id
}


resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "db-sg"
  vpc_id      = aws_vpc.sprint_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



output "db_security_group_id" {
  value = aws_security_group.db_sg.id
}