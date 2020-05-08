# docker_dev

This is my personal dev environment. It is based on ubuntu 20.04 and uses:

- ZSH with [my personal dot files](https://github.com/elafo/zsh-dot-files)
- Git with [my personal dot files](https://github.com/elafo/git-dot-files)
- Vim with [my personal dot files](https://github.com/elafo/vim-dot-files)
- [rbenv](https://github.com/rbenv/rbenv) for ruby development

# How to use this image

```bash
docker run --rm -it elafo/dev_docker
```

## Mounting workspaces
If you want to bind mount your workspace you can bind it to /workspace

```bash
docker run --rm -it -v $(PWD):/workspace elafo/dev_docker
```

### Automatic installation of ruby version and persisting rubies
If you bind mount a directory with a `.ruby-version` file in its root, the proper version will be installed at start.

If this is the case, then you might want to mount a volume to persist the rubies, so it is already installed next time you start your container

```bash
docker run --rm -it -v rubies:/root/.rbenv -v $(PWD):/workspace elafo/dev_docker
```
## Volumes

|Path|Description|
|----|:----------|
|`/workspace`|main folder for developing|
|`/root/.rbenv`|rbenv folder where rubies and gems are installed|

# Building the image
## Args

|Build arg|Description|Default value|
|---------|:----------|:------------|
| `ruby_global`|ruby version to be installed globally using rbenv|2.7.0|
|`ruby_versions`| extra ruby versions to be installed using rbenv|none|

## Example

```bash
docker build --build-arg ruby_global=2.6.0 --build-arg ruby_versions="2.5.0 2.4.0" -t dev:local .
```