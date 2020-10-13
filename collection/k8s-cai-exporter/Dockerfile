FROM docker.io/google/cloud-sdk:314.0.0-alpine
RUN apk update && \
    apk add jq curl vim && \
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin
ADD k8s-export.sh /k8s-export.sh
RUN chmod +x /k8s-export.sh
CMD ["/k8s-export.sh"]
