
# set variables
DOCKER_IMAGE="${dockerImage}" 
IMAGE_TAG="${imageTag}"
DOCKERFILE="${dockerFile}"
OUTPUT_DIR=`pwd` # use another dir (archive dir?)

# check DOCKER_IMAGE or DOCKERFILE is given
if [ -z "$DOCKER_IMAGE" ] && [ -z "$DOCKERFILE" ]; then
        echo "Docker image or Dockerfile not provided. Terminating job ${AGAVE_JOB_ID}"  >&2
        ${AGAVE_JOB_CALLBACK_FAILURE}
        exit
fi

# pull or build docker container
if [ -z "$DOCKERFILE" ]; then
        DOCKER_IMAGE="$DOCKER_IMAGE:$IMAGE_TAG"
        docker pull $DOCKER_IMAGE
else
        if [ -z $DOCKER_IMAGE ]; then
                DOCKER_IMAGE="docker-to-singularity-image"
        fi
        DOCKERFILE_DIR=`dirname $DOCKERFILE`
        docker build -t $DOCKER_IMAGE $DOCKERFILE_DIR
fi

# update docker2singularity
docker rmi johnfonner/docker2singularity
docker pull johnfonner/docker2singularity

# run docker2singularity
# docker run -v /var/run/docker.sock:/var/run/docker.sock -v $OUTPUT_DIR:/output --privileged -t --rm singularityware/docker2singularity $DOCKER_IMAGE
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $OUTPUT_DIR:/output --privileged -t --rm johnfonner/docker2singularity $DOCKER_IMAGE

# removed docker container if created via Dockerfile
#if [ ! -z "$DOCKERFILE" ]; then
#        docker rmi -f $DOCKER_IMAGE
#fi

# stop all running docker containers
docker stop $(docker ps -a -q)

# remove all docker images
docker rmi -f $(docker ps -a -q)
