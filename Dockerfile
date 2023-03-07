FROM k8s.gcr.io/kustomize/kustomize:v4.5.5

RUN apk add -u bash gettext moreutils

# kbld
RUN wget https://github.com/vmware-tanzu/carvel-kbld/releases/download/v0.35.0/kbld-linux-amd64 && \
    mv kbld-linux-amd64 ./kbld && \
    chmod +x ./kbld

# Install the AVP plugin
ENV AVP_VERSION=1.13.1
ENV BIN=argocd-vault-plugin
RUN wget -O ${BIN} https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64 && \
    chmod +x ${BIN}
