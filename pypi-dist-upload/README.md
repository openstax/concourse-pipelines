# pypi-dist-upload

All pypi uploads have been merged into one monolithic pipeline to reuse images and make changes that apply to all pipelines slightly easier.

## Generate the pipeline definition
To generate the pipeline you must have `npm` and `node` installed.

To install dependencies:
```
npm install
```

To generate the pipeline definition (on stdout):
```
node index.js
```

To set or update the pipeline on concourse, assuming your target is called `concourse-v6`:
```
fly -t concourse-v6 sp -p pypi-releases -c <(node index.js)
```
then, confirm the changes before accepting.

## Add another repo to the release list
To add another repo to the release list, you must only add an entry to `repos.js`.
e.g. 
```
{
  githubRepo: 'openstax/cnx-archive',
  setupOptions: 'bdist_wheel',
  pythonImageTag: '2.7'
},
```
will poll the `openstax/cnx-archive` repository and upload a new distribution to pypi, building with python2.7 when a new tag is pushed.
