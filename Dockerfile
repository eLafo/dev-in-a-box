FROM ubuntu:20.04
LABEL maintainer="eLafo"

# BASE
## BUILD ARGS
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

ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT [ "/root/entrypoint.sh" ]
CMD [ "zsh" ]