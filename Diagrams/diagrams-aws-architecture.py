from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, InternetGateway, RouteTable, ELB
from diagrams.aws.compute import EC2, Lambda
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.client import Users

with Diagram("Arquitetura Web AWS com ETL de Imagens", show=False, outformat="png", filename="diagrams/aws_web_architecture_etl"):
    client = Users("Cliente")
    igw = InternetGateway("Internet Gateway")

    client >> igw

    with Cluster("VPC - Rede principal"):
        rt = RouteTable("Route Table")
        vpc = VPC("VPC")

        igw >> rt 

        elb_private = ELB("ELB Privada")

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

        # Cliente acessa front-ends via rota
        rt >> [fe1, fe2]

        # Comunicação entre camadas
        fe1 >> elb_private
        fe2 >> elb_private
        elb_private >> be1
        elb_private >> be2
        fe1 >> be1 >> db1
        fe2 >> be2 >> db2

        # Buckets e Lambda do processo ETL
        s3_raw = S3("bucket-refuge-img-raw")
        lambda_etl = Lambda("funcao1_terraform (Lambda ETL)")
        s3_trusted = S3("bucket-refuge-img-trusted")

        # Fluxo ETL de imagem
        be1 >> Edge(label="envia imagem") >> s3_raw
        be2 >> Edge(label="envia imagem") >> s3_raw

        s3_raw >> Edge(label="dispara trigger") >> lambda_etl
        lambda_etl >> Edge(label="salva imagem processada") >> s3_trusted

        # Backend consome imagem do bucket trusted
        s3_trusted >> Edge(label="consome imagem processada") >> [be1, be2]

        # Monitoramento
        cw = Cloudwatch("CloudWatch")
        db1 >> cw
        db2 >> cw
