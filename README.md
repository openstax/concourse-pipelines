## Overview

The repository contains various [Concourse CI](https://concourse-ci.org) pipeline definitions. Most pipeline definitions live with the code they are intended to be used with, however some pipelines do not have code. This space is used to house those pipelines that are code or service independent.

## Releasing of Python Packages

See the [./pypi-dist-upload/README.md](./pypi-dist-upload/README.md) file to learn more.

## Testing a local pipeline by example

Let's say we would like to test a pipeline that pushes a new docker hub image whenever a new tag is pushed to a git repository. First, we should take a look at the docker-compose.yml file included in this repo.

```yml
# docker-compose.yml
version: '3.7'
services:
  concourse-db:
    image: postgres:12
    # ...

  concourse:
    image: concourse/concourse:4.2.2
    ports: ["8080:8080"]
    # ...

  docker-registry:
    restart: always
    image: registry:2
    ports: ["5000:5000"]

  git-server:
    image: tomjw64/git-server
    ports: ["8090:8000"]
```

There are a couple services here that can help us with our task. First, we have a concourse service (and a postgres db to back it). We can use this to run our pipelines locally. Second, is an insecure docker registry service, which we can use to mock out the Docker Hub registry without actually pushing anything remotely. Third is an insecure git http server, which we can use to mock out a git repository without actually pushing anything remotely.

Let's start by writing out the resources to our task:
```yml
# pipeline.yml
resources:
  - name: source-code-tagged
    type: git
    source:
      uri: http://git-server:8000/my-stuff  # We are pointing to the git server in docker-compose
      tag_filter: '*'

  - name: docker-hub-image
    type: registry-image
    source:
      repository: docker-registry:5000/my-stuff  # We are pointing to the docker registry in docker-compose
      insecure_registries: ["docker-registry:5000"]  # Important that we specify that the registry is insecure
```

Next, we'll tack on a job to do the actual work. This should hopefully not change depending on what our docker registry and git endpoints are.
```yml
# pipeline.yml
# ...
jobs:
  - name: build-and-publish-tagged-image
    public: true
    plan:
      - get: source-code-tagged
        trigger: true
      - put: docker-hub-image
        params:
          build: source-code-tagged
          tag_as_latest: true
```

Next, we will start our services, set the concourse pipeline, push our git repo, unpause the pipeline, tag our repo and watch the result.
```bash
$ docker-compose up -d
# Creating network "concourse-pipelines_default" with the default driver
# Creating concourse-pipelines_docker-registry_1 ... done
# Creating concourse-pipelines_concourse-db_1    ... done
# Creating concourse-pipelines_git-server_1      ... done
# Creating concourse-pipelines_concourse_1       ... done
$ fly -t dev login -c http://localhost:8080  # And jump through the hoops
# logging in to team 'main'

# navigate to the following URL in your browser:

#   http://localhost:8080/sky/login?redirect_uri=http://127.0.0.1:33891/auth/callback

# or enter token manually:
# target saved
$ fly -t dev set-pipeline -c pipeline.example.yml -p my-stuff-image
# ...
apply configuration? [yN]: y
# pipeline created!
# you can view your pipeline here: http://localhost:8080/teams/main/pipelines/my-stuff-image

# the pipeline is currently paused. to unpause, either:
#   - run the unpause-pipeline command
#   - click play next to the pipeline in the web ui
$ cd /tmp/my-stuff  # Must already be a git repo and have a Dockerfile
$ git remote add local-pipeline http://localhost:8090/my-stuff
$ git push local-pipeline --all
$ fly -t dev unpause-pipeline -p my-stuff-image
$ git tag my-tag
$ git push local-pipeline my-tag
# ...We wait for our build to succeed and then check our insecure docker registry for the image
$ curl http://localhost:5000/v2/my-stuff/tags/list
# {"name":"my-stuff","tags":["latest"]}
```

Hooray! Our pipeline did its job. Now we have to modify the pipeline back to point to the remote services:
```yml
# pipeline.yml
resources:
  - name: source-code-tagged
    type: git
    source:
      uri: http://git-server:8000/my-stuff  # Change this line to point to remote repo. Probably https://github.com/openstax/my-repo.
      tag_filter: '*'

  - name: docker-hub-image
    type: registry-image
    source:
      repository: docker-registry:5000/my-stuff  # Change this line to point to remote registry. Probably openstax/my-stuff (with no explicit host).
      insecure_registries: ["docker-registry:5000"]  # Remove this line
```

Thanks for reading and good luck!

## License

This software is subject to the provisions of the GNU Affero General
Public License Version 3.0 (AGPL). See license.txt for details.
Copyright (c) 2019 Rice University

