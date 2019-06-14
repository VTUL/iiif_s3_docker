# IIIF_S3 docker
This project packages [iiif_s3](https://github.com/cmoa/iiif_s3) into a docker image

## Getting Started
* Usage
```
docker run  --env AWS_ACCESS_KEY_ID=**** -e AWS_SECRET_ACCESS_KEY="****" -e AWS_BUCKET_NAME=s3_bucket_name -e AWS_REGION=region -it -v mount_path docker_image ./createiiif.sh /path_to_csv_file /path_to_image_Access_folder/ https://s3-region.amazonaws.com/bucket s3_target_bucket true
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