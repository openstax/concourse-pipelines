# pypi-dist-upload

The [./pipeline.yml](./pipeline.yml) included in the root of this directory is used to setup multiple Concourse pipelines for each python distribution utilizing variable substitution. The files that provide the variables are located in the [./vars](./vars) directory. The name of the file in [./vars](./vars) represents the package that will be uploaded to pypi. For example, [./vars/cnx-db.yml](./vars/cnx-db.yml) is the file for the [pypi/cnx-db](https://pypi.org/project/cnx-db/) package.

## Creating a pypi-dist-upload pipeline

* Copy the template file in [./vars/template.yml](./vars/template.yml) and overwrite with the appropriate name.

```bash
cp ./vars/template.yml ./vars/new-app.yml
```

* Open the new file and substitute the required values

**EXAMPLE**  
```yaml
github-repo: openstax/new-app  
setup-options: bdist_wheel --universal  
python-image-tag: 3  
```

* Create the pipeline in Concourse by using the fly command and identifying the necessary file in the vars directory. Substitute with the appropriate values.

```bash
fly -t <target> set-pipeline --pipeline=<release-new-app> --config=./pipeline.yml --yaml-vars-from=<./vars/my-app.yml>
```

## Update an already existing release pipeline

* Run the `fly` command to `set-pipeline` using the existing vars file and pipeline file.

```bash
fly -t <target> set-pipeline --pipeline=release-cnx-deploy --config=./pipeline.yml --yaml-vars-from=./vars/cnx-db.yml
```
