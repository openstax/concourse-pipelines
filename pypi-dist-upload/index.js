const yaml = require('js-yaml')
const dedent = require('dedent')
const { repos } = require('./repos')

const dockerCredentials = {
  username: '((ce-dockerhub-id))',
  password: '((ce-dockerhub-token))'
}

const createPythonImageResource = ({ resourceName, pythonImageTag }) => {
  return {
    name: resourceName,
    type: 'registry-image',
    source: {
      repository: 'python',
      tag: pythonImageTag,
      ...dockerCredentials
    }
  }
}
const createGitResource = ({ resourceName, githubRepo }) => {
  return {
    name: resourceName,
    type: 'git',
    source: {
      uri: `https://github.com/${githubRepo}.git`,
      tag_filter: '*'
    }
  }
}
const createReleaseJob = ({ gitResourceName, setupOptions, pythonResourceName }) => {
  return {
    name: `dist upload from ${gitResourceName}`,
    build_log_retention: {
      builds: 3,
      minimum_succeeded_builds: 1
    },
    public: true,
    serial: true,
    plan: [
      {
        get: pythonResourceName
      },
      {
        get: CURL_IMAGE_NAME
      },
      {
        get: gitResourceName,
        trigger: true
      },
      {
        task: 'twine upload',
        image: pythonResourceName,
        config: {
          platform: 'linux',
          inputs: [{name: gitResourceName}],
          outputs: [{name: 'release-link'}],
          params: {
            TWINE_USERNAME: '((pypi-username))',
            TWINE_PASSWORD: '((pypi-password))'
          },
          run: {
            path: '/bin/bash',
            args: [
              '-cx',
              dedent`
              set -eo pipefail
              cd ${gitResourceName}
              pip install -q twine
              python setup.py ${setupOptions}
              release_link=$(twine upload dist/* | tail -n 1)
              cd -
              [[ "$release_link" == *http* ]] || (echo 'Release link not a link' && exit 2)
              echo $release_link > release-link/release-link
              `
            ]
          }
        }
      }
    ],
    on_success: {
      task: 'notify slack',
      image: CURL_IMAGE_NAME,
      config: {
        platform: 'linux',
        inputs: [{name: 'release-link'}],
        params: {
          WEBHOOK_URL: '((slack-webhook-cestream))'
        },
        run: {
          path: '/bin/sh',
          args: [
            '-cxe',
            dedent`
            release_link=$(cat release-link/release-link)
            message="Released ${gitResourceName} on PyPi: $release_link"
            curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${'${message}'}\"}" "$WEBHOOK_URL"
            `
          ]
        }
      }
    }
  }
}

const OPENSTAX_PREFIX = 'openstax/'
const CURL_IMAGE_NAME = 'curl-image'

const curlImageResource = {
  name: CURL_IMAGE_NAME,
  type: 'registry-image',
  source: {
    repository: 'curlimages/curl',
    ...dockerCredentials
  }
}

const pythonResourcesVisited = []
const resources = [curlImageResource]
const jobs = []
for (const repo of repos) {
  const { githubRepo, setupOptions, pythonImageTag } = repo

  const pythonResourceName = `python-${pythonImageTag}`
  if (!pythonResourcesVisited.includes(pythonResourceName)) {
    pythonResourcesVisited.push(pythonResourceName)
    const pythonImageResource = createPythonImageResource({ resourceName: pythonResourceName, pythonImageTag })
    resources.push(pythonImageResource)
  }

  const gitResourceName = `github-${githubRepo.replace(OPENSTAX_PREFIX, '')}-${pythonImageTag}`
  const gitImageResource = createGitResource({ resourceName: gitResourceName, githubRepo })
  resources.push(gitImageResource)
  
  const job = createReleaseJob({ gitResourceName, setupOptions, pythonResourceName })
  jobs.push(job)
}

const pipelineDefinition = yaml.safeDump({ resources, jobs })
console.log(pipelineDefinition)
