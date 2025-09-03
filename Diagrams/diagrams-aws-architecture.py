from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, InternetGateway, RouteTable, ELB
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.client import Users

with Diagram("Arquitetura Web AWS", show=False, outformat="png", filename="diagrams/aws_web_architecture"):
    client = Users("Cliente")
    igw = InternetGateway("Internet Gateway")

    client >> igw

    with Cluster("VPC - Rede principal"):
        rt = RouteTable("Route Table")
        vpc = VPC("VPC")

        igw >> rt 

        elb_public = ELB("ELB Pública")
        elb_private = ELB("ELB Privada")

        rt >> elb_public

        with Cluster("Availability Zone 1"):
            with Cluster("Sub-Rede 1"):
                fe1 = EC2("Front-end 1")
            with Cluster("Sub-Rede 2"):
                be1 = EC2("Back-end 1")
                db1 = RDS("Banco de Dados 1")

        with Cluster("Availability Zone 2"):
            with Cluster("Sub-Rede 3"):
                fe2 = EC2("Front-end 2")
            with Cluster("Sub-Rede 4"):
                be2 = EC2("Back-end 2")
                db2 = RDS("Banco de Dados 2")

        elb_public >> [fe1, fe2]
        fe1 >> elb_private
        fe2 >> elb_private
        elb_private >> be1
        elb_private >> be2
        fe1 >> be1 >> db1
        fe2 >> be2 >> db2
        s3 = S3("Bucket S3")
        cw = Cloudwatch("CloudWatch")
        db1 >> s3
        db2 >> s3
        db1 >> cw
        db2 >> cw
