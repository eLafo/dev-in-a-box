FROM ubuntu:20.04
LABEL maintainer="eLafo"

# BASE
## BUILD ARGS
SHELL ["/bin/bash", "-c"]
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

# asdf
ENV ASDF_DIR=/root/.asdf
ARG asdf_version=0.7.8
RUN git clone https://github.com/asdf-vm/asdf.git ${ASDF_DIR}/.asdf --branch v${asdf_version}

## INSTALL rbenv and rubies
ARG ruby_version="2.7.0"
ENV RBENV_ROOT=/root/.rbenv
ENV PATH="${RBENV_ROOT}/shims:${RBENV_ROOT}/bin:$PATH"
ENV RUBY_CONFIGURE_OPTS --disable-install-doc

RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash && \
      rbenv install ${ruby_version} && \
      rbenv global ${ruby_version}

## INSTALL HOMESICK FOR DOTFILES
RUN gem install homesick

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

## INSTALL CHROME
ENV DEBIAN_FRONTEND=noninteractive
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && apt-get clean

# NODE DEV
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}:$PATH"
ARG node_version=node

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash && \
      . $NVM_DIR/nvm.sh && \
      nvm install ${node_version} && \
      nvm alias default node

# PYTHON DEV
ENV PYENV_ROOT=/root/.pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"
ARG python_version=3.8.2
RUN curl https://pyenv.run | bash && \
    pyenv install ${python_version} && \
    pyenv global ${python_version}

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

# PHP
ARG php_version=7.4.5


RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      libxml2-dev pkg-config libcurl4-openssl-dev libpng-dev re2c libsqlite3-dev libonig-dev libzip-dev locate
RUN . ${ASDF_DIR}/.asdf/asdf.sh && \
      asdf plugin add php https://github.com/asdf-community/asdf-php.git && \
      asdf install php ${php_version} && \
      asdf global php ${php_version}

ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT [ "/root/entrypoint.sh" ]
CMD [ "zsh" ]