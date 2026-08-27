FROM amazonlinux
WORKDIR /project
COPY . .
RUN yum install -y java-21-amazon-corretto-devel maven && mvn clean package -DskipTests

CMD ["java", "-jar", "target/aws-final-project-with-docker-terraform-ci-cd-1.0-SNAPSHOT.jar"]