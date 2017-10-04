path = require("path")
awspublish = require('gulp-awspublish')
human = require("human-interval")
la = require("lazy-ass")
check = require("check-more-types")
cp = require("child_process")
fs = require("fs")
os = require("os")
{configFromEnvOrJsonFile, filenameToShellVariable} = require('@cypress/env-or-json-file')

getS3Credentials = () ->
  key = path.join('scripts', 'binary', 'support', '.aws-credentials.json')

  config = configFromEnvOrJsonFile(key)
  if !config
    console.error('⛔️  Cannot find AWS credentials')
    console.error('Using @cypress/env-or-json-file module')
    console.error('and filename', key)
    console.error('which is environment variable', filenameToShellVariable(key))
    throw new Error('AWS config not found')

  la(check.unemptyString(config.bucket), 'missing AWS config bucket')
  la(check.unemptyString(config.folder), 'missing AWS config folder')
  config

getPublisher = (getAwsObj = getS3Credentials) ->
  aws = getAwsObj()

  # console.log("aws.bucket", aws.bucket)
  awspublish.create {
    httpOptions: {
      timeout: human("10 minutes")
    }
    params: {
      Bucket:        aws.bucket
    }
    accessKeyId:     aws.key
    secretAccessKey: aws.secret
  }

hasCloudflareEnvironmentVars = () ->
  check.unemptyString(process.env.CF_TOKEN) &&
  check.unemptyString(process.env.CF_EMAIL) &&
  check.unemptyString(process.env.CF_DOMAIN)

# depends on the credentials file or environment variables
makeCloudflarePurgeCommand = (url) ->
  configFile = path.resolve(__dirname, "support", ".cfcli.yml")
  if fs.existsSync(configFile)
    console.log("using CF credentials file")
    return "cfcli purgefile -c #{configFile} #{url}"
  else if hasCloudflareEnvironmentVars()
    console.log("using CF environment variables")
    token = process.env.CF_TOKEN
    email = process.env.CF_EMAIL
    domain = process.env.CF_DOMAIN
    return "cfcli purgefile -e #{email} -k #{token} -d #{domain} #{url}"
  else
    throw new Error("Cannot form Cloudflare purge command without credentials")

purgeCache = (url) ->
  la(check.url(url), "missing url to purge", url)

  new Promise (resolve, reject) =>
    console.log("purging url", url)
    purgeCommand = makeCloudflarePurgeCommand(url)
    cp.exec purgeCommand, (err, stdout, stderr) ->
      if err
        console.error("Could not purge #{url}")
        console.error(err.message)
        return reject(err)
      console.log("#purgeCache: #{url}")
      resolve()

getUploadNameByOs = (osName = os.platform()) ->
  uploadNames = {
    darwin: "osx64"
    linux:  "linux64"
    win32:  "win64"
  }
  name = uploadNames[osName]
  if not name
    throw new Error("Cannot find upload name for OS #{osName}")
  name

saveUrl = (filename) -> (url) ->
  s = JSON.stringify({url})
  fs.writeFileSync(filename, s)

module.exports = {
  getS3Credentials,
  getPublisher,
  purgeCache,
  getUploadNameByOs,
  saveUrl
}
