ARG UBUNTU
FROM ubuntu:$UBUNTU

RUN echo "APT::Install-Recommends \"0\";\nAPT::Install-Suggests \"0\";" \
    > /etc/apt/apt.conf.d/99no-recommends
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        git \
        make \
        vim-nox \
        zsh \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN chsh -s /bin/zsh
ENV USER=root SHELL=/bin/zsh

RUN echo "OS=linux\nENV=home\nFORM=server" > ~/.defs.sh \
 && git clone https://github.com/sfiera/.dotfiles.git ~/.dotfiles \
 && cd ~/.dotfiles \
 && ./install \
 && rm -Rf ./**/.git*

ARG BUILD_DATE
ARG VERSION
LABEL maintainer="sfiera@twotaled.com"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.title="sfiera/dev"
LABEL org.opencontainers.image.description="Ubuntu image, configured for sfiera"
LABEL org.opencontainers.image.url="https://github.com/sfiera/.dotfiles/tree/master/linux/docker/dev"
LABEL org.opencontainers.image.version=$VERSION

CMD ["zsh", "-l"]
