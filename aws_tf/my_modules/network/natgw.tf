
# EIPの作成
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

# natゲートウェイの作成
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.sprint_sub["alb-subnet-01"].id

  tags = {
    Name = "nat-gateway"
  }
}

# API用ルートテーブルの作成
resource "aws_route_table" "sprint_route_table_api" {
  vpc_id = aws_vpc.sprint_vpc.id
  tags = {
    Name = "api-routetable"
  }
}


# API用ルート_natゲートウェイ向け
resource "aws_route" "sprint_api_route" {
  route_table_id         = aws_route_table.sprint_route_table_api.id
  gateway_id             = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}


# ルートテーブルとサブネットの関連付け(api)
resource "aws_route_table_association" "sprint_route_asso_nat_api" {
  for_each = {
    for key, subnet in aws_subnet.sprint_sub :
    key => subnet if contains(["api-subnet-01", "api-subnet-02"], subnet.tags["Name"])
  }

  route_table_id = aws_route_table.sprint_route_table_api.id
  subnet_id      = each.value.id
}

output "route_table_api_id" {
  value = aws_route_table.sprint_route_table_api.id
}
