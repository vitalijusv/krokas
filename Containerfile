ARG IMAGE_MAJOR_VERSION=40
ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/silverblue:${IMAGE_MAJOR_VERSION}

FROM ${BASE_IMAGE}

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install fish moreutils && \
    ostree container commit

RUN --mount=type=bind,source=cosign.pub,target=/run/krokas.pub,ro=true,U=true,relabel=private \
    mkdir -p /etc/pki/containers && cp /run/krokas.pub /etc/pki/containers/krokas.pub && \
    jq '.default as $default \
    | .default[0].type = "reject" \
    | .transports.docker."ghcr.io/vitalijusv/krokas"[0] |= (.type="sigstoreSigned" | .keyPath="/etc/pki/containers/krokas.pub" | .signedIdentity.type="matchRepository") \
    | .transports.docker."" = $default \
    | .transports."docker-daemon"."" = $default \
    | .transports.atomic."" = $default \
    | .transports."containers-storage"."" = $default \
    | .transports.dir."" = $default \
    | .transports.oci."" = $default \
    | .transports."oci-archive"."" = $default \
    | .transports."docker-archive"."" = $default \
    | .transports.tarball."" = $default \
    '  /etc/containers/policy.json | sponge /etc/containers/policy.json && \
    printf "docker:\n  ghcr.io/vitalijusv:\n    use-sigstore-attachments: true\n" > /etc/containers/registries.d/krokas.yaml && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install fira-code-fonts langpacks-en_GB && \
    ostree container commit

RUN rpm -Uvh $(curl -sL https://api.github.com/repos/VSCodium/vscodium/releases/latest | jq -r '.assets[] | select(.name | endswith("x86_64.rpm")) | .browser_download_url') && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install qemu-system-x86 qemu-img qemu-kvm && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install libvirt virt-manager && \
    ostree container commit

ARG IMAGE_MAJOR_VERSION
RUN rpm -Uvh https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${IMAGE_MAJOR_VERSION}.noarch.rpm && \
    rpm -Uvh https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${IMAGE_MAJOR_VERSION}.noarch.rpm && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld.x86_64 \
    --install libva-utils --install vdpauinfo --install mesa-vdpau-drivers-freeworld.x86_64 && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree override remove libavcodec-free libavfilter-free libavformat-free libavutil-free libpostproc-free libswresample-free libswscale-free \
        --install gstreamer1-plugins-bad-freeworld --install gstreamer1-plugins-ugly \
        --install pipewire-codec-aptx --install libheif-freeworld \
        --install ffmpeg --install ffmpeg-libs && \
    ostree container commit
