# IIIF_S3 docker
This project packages [image-iiif-s3](https://github.com/VTUL/image-iiif-s3) into a docker image

## Getting Started
* Build the docker image
```
docker build -t="docker_image" .
```

* Usage
```
docker run --env-file ./env.list -it -v mount_path:container_path docker_image
```

* Environment variables
	* AWS_ACCESS_KEY_ID: AWS access keys
	* AWS_SECRET_ACCESS_KEY: AWS secret access key
	* AWS_REGION: AWS region, e.g. us-east-1
	* AWS_BUCKET_NAME: S3 bucket name
	* ACCESS_DIR: /path_to_image_folder to be processed
	* DEST_FOLDER: Target folder inside the S3 bucket (AWS_BUCKET_NAME)
	* CSV_NAME: A [CSV file](examples/example.csv) with title and description of the images
	* DEST_URL: Root URL for accessing the manifests e.g. https://s3.amazonaws.com/iiif-example
	* UPLOAD_BOOL: upload tiles and manifests to S3 (true|false)

* Enviornment variables file: [env.list](env.list)

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
* [image-iiif-s3](https://github.com/VTUL/image-iiif-s3)