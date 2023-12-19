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

# Install Helm for Helm + Kustomize
ENV HELM_VERSION=v3.12.0
ENV HELM_SHA256SUM=87596f12f202513ee694add15c252cf93cde49bc1e5160ca2dbcad93304a7d27
ENV TAR_FILE="helm-${HELM_VERSION}-linux-amd64.tar.gz"
ENV BASE_URL="https://get.helm.sh"

# Helm 3.x
RUN curl -L ${BASE_URL}/${TAR_FILE} | tar xvz && \
    sha256sum linux-amd64/helm && \
    echo "$HELM_SHA256SUM  linux-amd64/helm" | sha256sum -c && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64

# Hack for kustomize
# In order to use a private helm chart repository
COPY ./helm4kustomize .

# Helm Git
ENV HELMGIT_PLUGIN_VERSION=0.15.1
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELMGIT_PLUGIN_VERSION}"
