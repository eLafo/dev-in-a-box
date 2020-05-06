# docker_dev

This is my personal dev environment

# Building the image
## Args

|Build arg|Description|Default value|
|---------|:----------|:------------|
| ruby_version|tag of the ruby image which the image will inherit from. Must be debian based|2.5.8|
|bundler_version| bundler version to be installed|1.17.3|

## Example

```bash
docker build --build-arg ruby_version=2.6 --build-arg bundler_version=2.1.4 -t dev:local .
```