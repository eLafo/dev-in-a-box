FROM ubuntu:20.04
LABEL maintainer="eLafo"

# BASE
## BUILD ARGS
SHELL ["/bin/bash", "-l", "-c"]
ARG workspace=/workspace
ENV WORKSPACE=$workspace

## SET LOCALE
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&\
    sed -i -e 's/# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen

RUN locale-gen en_US.UTF-8 es_ES.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## CREATING WORKSPACE
RUN mkdir ${WORKSPACE}
WORKDIR ${WORKSPACE}

## LIBRARIES AND TOOLS
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      git \
      curl \
      wget \
      libpq-dev \
      autoconf \
      bison \
      build-essential \
      libssl-dev \
      libyaml-dev \
      libreadline6-dev \
      zlib1g-dev \
      libncurses5-dev \
      libffi-dev \
      libgdbm6 \
      libgdbm-dev \
      libdb-dev

## INSTALL CHROME
ENV DEBIAN_FRONTEND=noninteractive
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && apt-get clean

# DOCKER
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu eoan stable" && \
    apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y docker-ce docker-ce-cli containerd.io

# DOCKER COMPOSE
RUN curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose version

# ASDF
ENV ASDF_DIR=/root/.asdf
ARG asdf_version=0.7.8
RUN git clone https://github.com/asdf-vm/asdf.git ${ASDF_DIR} --branch v${asdf_version}
RUN echo ". ${ASDF_DIR}/asdf.sh" >> ~/.bash_profile

## INSTALL asdf-ruby and global ruby
ARG ruby_version
ENV RUBY_CONFIGURE_OPTS --disable-install-doc
RUN asdf plugin add ruby
RUN [[ ! -z "$ruby_version" ]] && \
      asdf install ruby ${ruby_version} && asdf local ruby ${ruby_version} || \
      echo "No asdf ruby installed"

# NODE DEV
ARG node_version
RUN asdf plugin add nodejs && \
    . ${ASDF_DIR}/plugins/nodejs/bin/import-release-team-keyring
RUN [[ ! -z "$node_version" ]] && \
      asdf install nodejs ${node_version} && asdf local nodejs ${node_version} || \
      echo "No asdf node installed"

# PYTHON DEV
ARG python_version
RUN asdf plugin add python && \
    apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      libsqlite3-dev libbz2-dev
RUN [[ ! -z "$python_version" ]] && \
      asdf install python ${python_version} && asdf local python ${python_version} || \
      echo "No asdf python installed"

# PHP
ARG php_version
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      libxml2-dev pkg-config libcurl4-openssl-dev libpng-dev re2c libsqlite3-dev libonig-dev libzip-dev locate && \
    asdf plugin add php https://github.com/asdf-community/asdf-php.git
RUN [[ ! -z "$php_version" ]] && \
      asdf install php ${php_version} && asdf local php ${php_version} || \
      echo "No asdf php installed"

## INSTALL HOMESICK
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      ruby && \
    asdf global ruby system && \
    gem install homesick

## INSTALL ZSH
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      fonts-powerline \
      zsh && \
    chsh -s $(which zsh)
RUN homesick clone eLafo/zsh-dot-files && \
    homesick symlink --force=true zsh-dot-files && \
    $(which zsh) -c "source ~/.zshrc"

## INSTALL AND SETUP VIM
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      vim \
      ack-grep

RUN homesick clone https://github.com/eLafo/vim-dot-files.git &&\
    homesick symlink vim-dot-files &&\
    exec vim -c ":PluginInstall" -c "qall"

## CONFIGURE GIT
RUN homesick clone eLafo/git-dot-files &&\
    homesick symlink git-dot-files

ADD fonts/* /usr/share/fonts/truetype/MesloLGS/
RUN fc-cache -fv

ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-l", "/root/entrypoint.sh" ]
CMD [ "zsh" ]