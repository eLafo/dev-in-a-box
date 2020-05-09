# Dev in a box

This is my personal dev environment. It is based on ubuntu 20.04 and uses:

- ZSH with [my personal dot files](https://github.com/elafo/zsh-dot-files)
- Git with [my personal dot files](https://github.com/elafo/git-dot-files)
- Vim with [my personal dot files](https://github.com/elafo/vim-dot-files)
- [rbenv](https://github.com/rbenv/rbenv) for ruby development
- [nvm](https://github.com/nvm-sh/nvm) for node development
- [pyenv](https://github.com/pyenv/pyenv) for python development

# How to use this image

```bash
docker run --rm -it elafo/dev-in-a-box
```

## Mounting workspaces
If you want to bind mount your workspace you can bind it to /workspace

```bash
docker run --rm -it -v $(PWD):/workspace elafo/dev-in-a-box
```

## Ruby development using rbenv
If you bind mount a directory with a `.ruby-version` file in its root, the proper version will be installed at start.

If this is the case, then you might want to mount a volume to persist the rubies, so it is already installed next time you start your container

```bash
docker run --rm -it -v rubies:/root/.rbenv -v $(PWD):/workspace elafo/dev-in-a-box
```

## Node development using nvm
If you bind mount a directory with a `.nvmrc` file in its root, the proper version will be installed at start.

If this is the case, then you might want to mount a volume to persist the nodes, so it is already installed next time you start your container

```bash
docker run --rm -it -v rubies:/root/.nvm -v $(PWD):/workspace elafo/dev-in-a-box
```

## Python development using pyenv
If you bind mount a directory with a `.python-version` file in its root, the proper version will be installed at start.

If this is the case, then you might want to mount a volume to persist the pyenvs, so it is already installed next time you start your container

```bash
docker run --rm -it -v pyenvs:/root/.pyenv -v $(PWD):/workspace elafo/dev-in-a-box
```
## Volumes

|Path|Description|
|----|:----------|
|`/workspace`|main folder for developing|
|`/root/.rbenv`|rbenv folder where rubies and gems are installed|
|`/root/.nvm`|nvm folder where nodes are installed|
|`/root/.pyenv`|pyenv folder where pyenvs are installed|

# Building the image
## Args

|Build arg|Description|Default value|
|---------|:----------|:------------|
| `ruby_version`|ruby version to be installed globally using rbenv|2.7.0|
|`node_version`|node version to be installed and used by default using nvm|latest|
|`python_version`|python version to be installed and used globally using pyenv|3.8.2|

## Example

```bash
docker build --build-arg ruby_version=2.6.0 --build-arg=node_version="lts" --build-arg python_version=3.8.0 -t dev:local .
```