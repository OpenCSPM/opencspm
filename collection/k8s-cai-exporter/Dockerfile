FROM gcr.io/google.com/cloudsdktool/cloud-sdk:331.0.0-alpine
RUN apk update && \
    apk add jq curl vim && \
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin

ENV HOME=/tmp
WORKDIR /tmp

ADD k8s-export.sh /tmp/k8s-export.sh
RUN chmod +x /tmp/k8s-export.sh

CMD ["/tmp/k8s-export.sh"]
