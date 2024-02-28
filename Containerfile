FROM quay.io/fedora/fedora-silverblue:39

RUN rpm -Uvh https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-39.noarch.rpm && \
    rpm -Uvh https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-39.noarch.rpm && \
    ostree container commit

RUN rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld.x86_64 && \
    ostree container commit

RUN rpm-ostree override remove  libavcodec-free libavfilter-free libavformat-free libavutil-free libpostproc-free libswresample-free libswscale-free \
        --install ffmpeg --install ffmpeg-libs && \
    ostree container commit

RUN rpm-ostree install fish fzf zstd htop && \
    ostree container commit

RUN rpm-ostree install fira-code-fonts langpacks-en_GB && \
    ostree container commit

RUN rpm-ostree install qemu-system-x86 qemu-img qemu-kvm && \
    ostree container commit

RUN rpm-ostree install libvirt virt-manager && \
    rm var/lib/unbound/root.key && \
    ostree container commit
