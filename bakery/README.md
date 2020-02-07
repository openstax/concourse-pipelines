## Bakery Concourse Pipeline Generator

### Setup
- Install NodeJS and `yarn` on your machine.
- Ensure `bakery/` is your working directory.
- Run `yarn install` or `yarn`.

### Generate a pipeline file for a particular environment
Run `yarn build:<env>`

Available environments: `local`, `staging`, `prod`, `all`

Example: `yarn build:staging`

Note: Directory for output path must exist. If no path argument is given, the pipeline will output to stdout.

### Generate a standalone task file suitable for `fly execute`
Run `yarn build:task <task-name> [yaml-object]`

Available tasks: `look-up-book`, `fetch-book`, `assemble-book`, `bake-book`, `mathify-book`, `build-pdf` (i.e. anything in the `tasks` directory)

Example: `yarn build:task look-up-book "{bucketName: my-bucket}"`
Example: `yarn build:task bake-book"`

Note: The optional `yaml-object` is passed directly to the task function as the first argument.

### Development
- There is no test suite in this repo, but a `yarn lint` command is provided to lint your work. This project uses `standard` to lint.
- Recommended way to verify your work is to go to the `output-producer-service` repository, start the `docker-compose` services in dev mode, and set-pipeline on the included concourse instance with a generated file by this repository.