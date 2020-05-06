ARG ruby_version=2.5.8

FROM ruby:${ruby_version}
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

## INSTALL HOMESICK FOR DOTFILES
RUN gem install homesick

## INSTALL CHROME
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && apt-get clean

## INSTALL ZSH
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      fonts-powerline \
      zsh

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN homesick clone eLafo/zsh-dot-files && \
    homesick symlink --force=true zsh-dot-files && \
    chsh -s $(which zsh) && \
    $(which zsh) -c "source ~/.zshrc"

## INSTALL AND SETUP VIM
RUN apt-get update -qq && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && apt-get install -y \
      vim

RUN homesick clone https://github.com/eLafo/vim-dot-files.git &&\
    homesick symlink vim-dot-files &&\
    exec vim -c ":PluginInstall" -c "qall"

## CONFIGURE GIT
RUN homesick clone eLafo/git-dot-files &&\
    homesick symlink git-dot-files

# RUBY
## BUILD ARGS
ARG bundler_version=1.17.3
ENV BUNDLER_VERSION=$bundler_version

## BUNDLER
RUN gem install bundler --version ${BUNDLER_VERSION}         

CMD [ "zsh" ]