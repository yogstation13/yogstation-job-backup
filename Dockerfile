FROM alpine:3.12

RUN apk add zip curl mariadb-client

RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.19.2/bin/linux/amd64/kubectl" && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

ADD ./backup.sh ./backup.sh
RUN chmod +x ./backup.sh

ENTRYPOINT [ "./backup.sh" ]