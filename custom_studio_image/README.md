
# Run a custom R environment on SageMaker Studio

## Overview
You can develop your own, custom environment that can be used within SageMaker. This allows you to use custom frameworks and configurations. To do this, you can extend example Docker files provided by SageMaker or build you own images from scratch. 

This example will demonstrate creating a custom R image. 

## Output
* After running this example, you will have a custom R image that you can run via SageMaker Studio. 
* You will understand the workflow required to deploy and use a custom image
* You will be able to customise an image to suit your own requirements 

## Prerequisites 
* After creating the custom image, you associate it with a SageMaker domain, so you need a domain created and permissions to do this
* Docker installed locally (where you are running the code)
* Amazon Elastic Container Registry where you have permissions to create a repository to hold the custom image 
* AWS CLI installed locally
* Python - this example uses the *sagemaker-studio-image-build* library as a convenience, but you can use docker and the aws cli locally to build and push the image to ECR instead if you prefer. 

## Steps

The example assumes all files are created within the same directory location. 

1. Create the ```Dockerfile``` that defines your custom image. You can view the [SageMaker examples](https://github.com/aws-samples/sagemaker-studio-custom-image-samples). For this example, the Dockerfile is based on the [r-image example](https://github.com/aws-samples/sagemaker-studio-custom-image-samples/tree/main/examples/r-image). You can find specifications for a custom image [here](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-byoi-specs.html)


2. Install SageMaker studio image build cli ```pip install sagemaker-studio-image-build```

3. Ensure you are authenticated with the aws cli. The role you use needs trust policy for CodeBuild as below
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
It also needs permissions to execute required Code Build processes. You can specify a role to use with the ```--role``` flag. For more information, see the [project on GitHub](https://github.com/aws-samples/sagemaker-studio-image-build-cli).

The build command will: 
* Zip the local files and upload to S3 (by default the SageMaker default bucket) to act as the source for the code build 
* Create an ECR repository by default called *sagemaker-studio* and by default apply an image tag of *latest*

Run ```sm-docker build . --repository sagemaker-studio:custom-r``` in the location of the Dockerfile. 


4. Once finished, you'll have your custom image available in the ECR repository. So next, create a SageMaker custom image that references the ECR image. Pass your SageMaker execution role ARN 
```
aws sagemaker create-image \
    --region ${REGION} \
    --image-name custom-r \
    --role-arn ${ROLE_ARN}
```

Then create the image version using your custom image URI
```
aws sagemaker create-image-version \
    --region ${REGION} \
    --image-name custom-r \
    --base-image ${IMAGE_URI}
```

5. Create ```app-image-config-input.json``` which holds configuration for the image. See [app-image-config-input.json](app-image-config-input.json) for example content. Then create the config. 
```
aws sagemaker create-app-image-config \
    --region ${REGION} \
    --cli-input-json file://app-image-config-input.json
```

6. Finally, Create ```default-user-settings.json```. See [default-user-settings.json](default-user-settings.json) for example content. Update your SageMaker domain to use the custom image. Specify the domain id where you want to use the custom image. 
```
aws sagemaker update-domain --domain-id ${DOMAIN_ID} \
    --region ${REGION} \
    --cli-input-json file://default-user-settings.json
```


You can now launch Studio within the respective domain and choose the custom image. 


