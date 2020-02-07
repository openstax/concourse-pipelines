const fs = require('fs')
const yaml = require('js-yaml')

const taskName = process.argv[2]
const taskArgs = yaml.safeLoad(process.argv[3])
const outputFile = process.argv[4]

const task = (() => {
  try {
    return require(`./tasks/${taskName}`)
  } catch {
    throw Error(`Could not find task file: ./tasks/${taskName}`)
  }
})()
const taskConfig = task(taskArgs).config

const forward = fs.readFileSync('forward.yml', { encoding: 'utf8' })
const output = forward + yaml.safeDump(taskConfig)

if (outputFile) {
  fs.writeFileSync(outputFile, output)
} else {
  console.log(output)
}
