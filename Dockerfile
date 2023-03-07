FROM golang:alpine as builder

ENV KUSTOMIZE_VERSION=v4.5.5

RUN mkdir /build && \
    apk add --no-cache git && \
    git clone https://github.com/kubernetes-sigs/kustomize.git /build/

WORKDIR /build/kustomize

RUN CGO_ENABLED=0 GO111MODULE=on go build \
    -ldflags="-s -X sigs.k8s.io/kustomize/api/provenance.version=${VERSION}"

FROM govpf/alpine:3

WORKDIR /app
ENV PATH "$PATH:/app"

# install kustomize
RUN apk add --no-cache git openssh
COPY --from=builder /build/kustomize/kustomize /app/

# kbld
ENV KBLD_VERSION=v0.35.0
RUN apk add -u bash gettext moreutils

RUN wget https://github.com/vmware-tanzu/carvel-kbld/releases/download/${KBLD_VERSION}/kbld-linux-amd64 && \
    mv kbld-linux-amd64 ./kbld && \
    chmod +x ./kbld

# Install the AVP plugin
ENV AVP_VERSION=1.13.1
ENV BIN=argocd-vault-plugin
RUN wget -O ${BIN} https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64 && \
    chmod +x ${BIN}
