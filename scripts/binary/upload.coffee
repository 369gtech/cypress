awspublish = require('gulp-awspublish')
rename = require('gulp-rename')
debug = require('gulp-debug')
fs      = require("fs-extra")
cp      = require("child_process")
path    = require("path")
gulp    = require("gulp")
human   = require("human-interval")
konfig  = require("../../packages/server/lib/konfig")
Promise = require("bluebird")
meta    = require("./meta")
la      = require("lazy-ass")
check   = require("check-more-types")
{configFromEnvOrJsonFile, filenameToShellVariable} = require('@cypress/env-or-json-file')

fs = Promise.promisifyAll(fs)

uploadNames = {
  darwin: "osx64"
  linux:  "linux64"
  win32:  "win64"
}

## TODO: refactor this
# system expects desktop application to be inside a file
# with this name
zipName = "cypress.zip"

getUploadNameByOs = (os) ->
  name = uploadNames[os]
  if not name
    throw new Error("Cannot find upload name for OS #{os}")
  name

getS3Credentials = () ->
  key = path.join('scripts', 'binary', 'support', '.aws-credentials.json')

  config = configFromEnvOrJsonFile(key)
  if !config
    console.error('⛔️  Cannot find AWS credentials')
    console.error('Using @cypress/env-or-json-file module')
    console.error('and filename', key)
    console.error('which is environment variable', filenameToShellVariable(key))
    throw new Error('AWS config not found')
  config

module.exports = {
  getPublisher: ->
    aws = @getAwsObj()

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

  getAwsObj: ->
    getS3Credentials()

  # store uploaded application in subfolders by platform and version
  # something like desktop/0.20.1/osx64/
  getUploadDirName: ({version, platform}) ->
    aws = @getAwsObj()
    osName = getUploadNameByOs(platform)
    dirName = [aws.folder, version, osName, null].join("/")
    console.log("target directory %s", dirName)
    dirName

  hasCloudflareEnvironmentVars: () ->
    check.unemptyString(process.env.CF_TOKEN) &&
    check.unemptyString(process.env.CF_EMAIL) &&
    check.unemptyString(process.env.CF_DOMAIN)

  # depends on the credentials file or environment variables
  makeCloudflarePurgeCommand: (url) ->
    configFile = path.resolve(__dirname, "support", ".cfcli.yml")
    if fs.existsSync(configFile)
      console.log("using CF credentials file")
      return "cfcli purgefile -c #{configFile} #{url}"
    else if @hasCloudflareEnvironmentVars()
      console.log("using CF environment variables")
      token = process.env.CF_TOKEN
      email = process.env.CF_EMAIL
      domain = process.env.CF_DOMAIN
      return "cfcli purgefile -e #{email} -k #{token} -d #{domain} #{url}"
    else
      throw new Error("Cannot form Cloudflare purge command without credentials")

  purgeCache: ({version, platform}) ->
    la(check.unemptyString(platform), "missing platform", platform)
    la(check.unemptyString(zipName), "missing zip filename")
    la(check.extension("zip", zipName),
      "zip filename should end with .zip", zipName)

    new Promise (resolve, reject) =>
      osName = getUploadNameByOs(platform)

      url = [konfig("cdn_url"), "desktop", version, osName, zipName].join("/")
      console.log("purging url", url)
      purgeCommand = @makeCloudflarePurgeCommand(url)
      cp.exec purgeCommand, (err, stdout, stderr) ->
        if err
          console.error("Could not purge #{url}")
          console.error(err.message)
          return reject(err)
        console.log("#purgeCache: #{url}")
        resolve()

  createRemoteManifest: (folder, version) ->
    getUrl = (uploadOsName) ->
      {
        url: [konfig('cdn_url'), folder, version, uploadOsName, zipName].join("/")
      }

    obj = {
      name: "Cypress"
      version: version
      packages: {
        mac: getUrl("osx64")
        win: getUrl("win64")
        linux64: getUrl("linux64")
      }
    }

    src = path.join(meta.buildDir, "manifest.json")
    fs.outputJsonAsync(src, obj).return(src)

  s3Manifest: (version) ->
    publisher = @getPublisher()

    aws = @getAwsObj()

    headers = {}
    headers["Cache-Control"] = "no-cache"

    new Promise (resolve, reject) =>
      @createRemoteManifest(aws.folder, version).then (src) ->
        gulp.src(src)
        .pipe rename (p) ->
          p.dirname = aws.folder + "/" + p.dirname
          p
        .pipe debug()
        .pipe publisher.publish(headers)
        .pipe awspublish.reporter()
        .on "error", reject
        .on "end", resolve

  toS3: ({zipFile, version, platform}) ->
    console.log("#uploadToS3 ⏳")
    la(check.unemptyString(version), "expected version string", version)
    la(check.unemptyString(zipFile), "expected zip filename", zipFile)
    la(check.extension("zip", zipFile),
      "zip filename should end with .zip", zipFile)
    la(meta.isValidPlatform(platform), "invalid platform", platform)

    console.log("zip filename #{zipFile}")
    if !fs.existsSync(zipFile)
      throw new Error("Cannot find zip file #{zipFile}")

    upload = =>
      new Promise (resolve, reject) =>
        publisher = @getPublisher()

        headers = {}
        headers["Cache-Control"] = "no-cache"

        gulp.src(zipFile)
        .pipe rename (p) =>
          # rename to standard filename zipName
          p.basename = path.basename(zipName, p.extname)
          p.dirname = @getUploadDirName({version, platform})
          p
        .pipe debug()
        .pipe publisher.publish(headers)
        .pipe awspublish.reporter()
        .on "error", reject
        .on "end", resolve

    upload()
    .then =>
      @purgeCache({version, platform})
}
