# Dev in a box

This is my personal dev environment. It is based on ubuntu 20.04 and uses:

- ZSH with [my personal dot files](https://github.com/elafo/zsh-dot-files)
- Git with [my personal dot files](https://github.com/elafo/git-dot-files)
- Vim with [my personal dot files](https://github.com/elafo/vim-dot-files)
- Docker and docker-compose
- [asdf](https://github.com/asdf-vm/asdf) and [asdf-php plugin](https://github.com/asdf-community/asdf-php) for development

# How to use this image

```bash
docker run --rm -it elafo/dev-in-a-box
```

## Mounting workspaces
If you want to bind mount your workspace you can bind it to /workspace

```bash
docker run --rm -it -v $(PWD):/workspace elafo/dev-in-a-box
```

## Supported languages via asdf

Versions are automatically installed if a `.tool-versions` file is in the root of the project like described [here](https://asdf-vm.com/#/core-configuration?id=tool-versions)

Legacy files are supported when available

|languaje|legacy file|
|----|:----------|
|ruby|`.ruby-version`|
|python|`.python-version`|
|node|`.node-version`|
|php|N/A|

You might want to use a volume to persist different versions between sessions:

```bash
docker run --rm -it -v asdf:/root/.asdf -v $(PWD):/workspace elafo/dev-in-a-box
```
## Sharing your ssh credentials
You need to bind mount your ssh directory:

```bash
docker run --rm -it -v ~/.ssh:/root/.ssh elafo/dev-in-a-box
```
## Using docker with host socket
You need to mount your host socket as usual:

```bash
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock elafo/dev-in-a-box
```
## Volumes

|Path|Description|
|----|:----------|
|`/workspace`|main folder for developing|
|`/root/.asdf`|asdf folder where shims are installed|
|`/var/run/docker.sock`|docker socket|
|`/root/.ssh`|ssh keys|

# Building the image
## Args

|Build arg|Description|Default value|
|---------|:----------|:------------|
| `ruby_version`|ruby version to be installed globally using rbenv|none|
|`node_version`|node version to be installed and used by default using nvm|none|
|`python_version`|python version to be installed and used globally using pyenv|none|
|`php_version`|php version to be installed and used globally using asf-php|none|

## Example

```bash
docker build --build-arg ruby_version=2.6.0 --build-arg=node_version="lts" --build-arg python_version=3.8.0 --build-arg php_version=7.4.1 -t dev:local .
```