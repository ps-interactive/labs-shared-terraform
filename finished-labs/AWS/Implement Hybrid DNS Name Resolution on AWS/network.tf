resource "aws_vpc" "on-prem" {
    cidr_block = "192.168.0.0/24"
    tags = {
        Name = "on-prem"
    }
}

resource "aws_default_vpc" "default" {
    tags = {
        Name = "default"
    }
}

resource "aws_vpc_peering_connection" "peer" {
    vpc_id = data.aws_vpc.default.id
    peer_vpc_id = aws_vpc.on-prem.id
    peer_owner_id = data.aws_caller_identity.self.account_id
    peer_region = "us-west-2"
    auto_accept = false
}

resource "aws_vpc_peering_connection_accepter" "peer" {
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    auto_accept = true
}

resource "aws_subnet" "on-prem-private" {
    vpc_id = aws_vpc.on-prem.id
    cidr_block = "192.168.0.0/26"
    availability_zone = data.aws_availability_zones.all.names[0]
    map_public_ip_on_launch = false
    tags = {
        Name = "on-prem-private"
    }
}

resource "aws_subnet" "on-prem-public" {
    vpc_id = aws_vpc.on-prem.id
    cidr_block = "192.168.0.64/26"
    availability_zone = data.aws_availability_zones.all.names[1]
    map_public_ip_on_launch = true
    tags = {
        Name = "on-prem-public"
    }
}

resource "aws_internet_gateway" "on-prem" {
    vpc_id = aws_vpc.on-prem.id
}

resource "aws_route_table" "on-prem-public" {
    vpc_id = aws_vpc.on-prem.id
}

resource "aws_route" "on-prem-public-default" {
    route_table_id = aws_route_table.on-prem-public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.on-prem.id
}

resource "aws_route" "on-prem-public-peer" {
    route_table_id = aws_route_table.on-prem-public.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route_table_association" "on-prem-public" {
    subnet_id = aws_subnet.on-prem-public.id
    route_table_id = aws_route_table.on-prem-public.id
}

resource "aws_eip" "nat" {
    vpc = true
}

resource "aws_nat_gateway" "on-prem" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.on-prem-public.id
}

resource "aws_route_table" "on-prem-private" {
    vpc_id = aws_vpc.on-prem.id
}

resource "aws_route" "on-prem-private-default" {
    route_table_id = aws_route_table.on-prem-private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.on-prem.id
}

resource "aws_route" "on-prem-private-peer" {
    route_table_id = aws_route_table.on-prem-private.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route_table_association" "on-prem-private" {
    subnet_id = aws_subnet.on-prem-private.id
    route_table_id = aws_route_table.on-prem-private.id
}

resource "aws_route" "default-peering" {
    route_table_id = data.aws_vpc.default.main_route_table_id
    destination_cidr_block = aws_vpc.on-prem.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
