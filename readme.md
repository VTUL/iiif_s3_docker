# IIIF_S3 docker
This project packages [iiif_s3](https://github.com/cmoa/iiif_s3) into a docker image

## Getting Started
* Build the docker image
```
docker build -t="iiifs3" .
```
* Usage
Adjust environment variables in `env.list` before running the script.
```
docker run --env-file ./env.list -it iiifs3
```

### Prerequisites
* Install [Docker](https://www.docker.com/)

### Installing
* Build the docker image
```
docker build -t="iiifs3" .
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/VTUL/iiif_s3_docker/tags). 

## Authors

* Digital Libraries Development developers

See also the list of [contributors](https://github.com/VTUL/iiif_s3_docker/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
* [iiif_s3](https://github.com/cmoa/iiif_s3)
