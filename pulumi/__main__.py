import os
import pulumi
import pulumi_tls as tls
import pulumi_aws as aws
import pulumi_command as command


private_key_filename = "private_key.pem"


def write_file(content):
    with open(private_key_filename, "w") as f:
        f.write(content)
    os.chmod(private_key_filename, 0o600)


ssh_key = tls.PrivateKey("ssh_key",
    algorithm="RSA",
    rsa_bits=4096
)

ssh_key.private_key_pem.apply(lambda c: write_file(c))

aws_key = aws.ec2.KeyPair("aws_key",
    key_name="pulumi_ec2_key",
    public_key=ssh_key.public_key_openssh
)

vpc = aws.ec2.Vpc("vpc",
    cidr_block="10.20.0.0/16",
    tags={
        "Name": "ec2_vpc",
    }
)

pub_subnet = aws.ec2.Subnet("pub_subnet",
    vpc_id=vpc.id,
    cidr_block="10.20.1.0/24",
    map_public_ip_on_launch=True
)

igw = aws.ec2.InternetGateway("igw",
    vpc_id=vpc.id
)

rt = aws.ec2.RouteTable("rt",
    vpc_id=vpc.id,
    routes=[
        aws.ec2.RouteTableRouteArgs(
            cidr_block="0.0.0.0/0",
            gateway_id=igw.id
        )
    ]
)

rta = aws.ec2.RouteTableAssociation("rta",
    subnet_id=pub_subnet.id,
    route_table_id=rt.id
)

sg = aws.ec2.SecurityGroup("sg",
    name="instance_access",
    vpc_id=vpc.id,
    ingress=[
        aws.ec2.SecurityGroupIngressArgs(
            from_port=22,
            to_port=22,
            protocol="tcp",
            cidr_blocks=["0.0.0.0/0"]
        ),
        aws.ec2.SecurityGroupIngressArgs(
            from_port=80,
            to_port=80,
            protocol="tcp",
            cidr_blocks=["0.0.0.0/0"]
        )
    ],
    egress=[
        aws.ec2.SecurityGroupEgressArgs(
            from_port=0,
            to_port=0,
            protocol="-1",
            cidr_blocks=["0.0.0.0/0"]
        )
    ]
)

ec2_instance = aws.ec2.Instance("ec2_instance",
    ami = "ami-0d497a49e7d359666", # Ubuntu, 20.04 LTS
    instance_type="t2.micro",
    subnet_id=pub_subnet.id,
    vpc_security_group_ids=[sg.id],
    key_name=aws_key.id,
    associate_public_ip_address=True,
    tags={
        "Name": "ec2_instance"
    }
)

remote_ssh_cmd = command.remote.Command("remote_exec",
    connection=command.remote.ConnectionArgs(
        host=ec2_instance.public_ip,
        port=22,
        user="ubuntu",
        private_key=ssh_key.private_key_pem
    ),
    create="echo 'Wait until SSH is ready'"
)

ansible_playbook_cmd = command.local.Command("local_exec",
    create=ec2_instance.public_ip.apply(lambda public_ip: f"ansible-playbook -i {public_ip}, --private-key {private_key_filename} nginx.yaml"),
    opts=pulumi.ResourceOptions(depends_on=[
        remote_ssh_cmd
    ])
)
