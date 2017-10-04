_         = require("lodash")
fs        = require("fs-extra")
Promise   = require("bluebird")
bumpercar = require("@cypress/bumpercar")
path      = require("path")
la        = require('lazy-ass')
check     = require('check-more-types')
R         = require("ramda")
{configFromEnvOrJsonFile, filenameToShellVariable} = require('@cypress/env-or-json-file')
makeEmptyGithubCommit = require("make-empty-github-commit")
parse = require("parse-github-repo-url")

fs = Promise.promisifyAll(fs)

car = null

PROVIDERS = {
  circle: [
    # "cypress-io/cypress-dashboard"
    # "cypress-io/cypress-core-example"
    # "cypress-io/cypress-core-desktop-gui"
    # "cypress-io/cypress-example-kitchensink"
    # "cypress-io/cypress-example-todomvc"
    # "cypress-io/cypress-example-piechopper"
    # "cypress-io/cypress-example-recipes"

    "cypress-io/cypress-test-module-api"
    "cypress-io/cypress-test-node-versions"
    "cypress-io/cypress-test-nested-projects"
    "cypress-io/cypress-test-ci-environments"
    "cypress-io/cypress-test-example-repos"
  ]

  # travis: [
  #   # "cypress-io/cypress-dashboard"
  #   "cypress-io/cypress-core-example"
  #   "cypress-io/cypress-core-desktop-gui"
  #   "cypress-io/cypress-example-kitchensink"
  #   "cypress-io/cypress-example-todomvc"
  #   "cypress-io/cypress-example-piechopper"
  #   "cypress-io/cypress-example-recipes"
  # ]
}

getCiConfig = ->
  key = "support/.ci.json"
  config = configFromEnvOrJsonFile(key)
  if !config
    console.error('⛔️  Cannot find CI credentials')
    console.error('Using @cypress/env-or-json-file module')
    console.error('and filename', key)
    console.error('which is environment variable', filenameToShellVariable(key))
    throw new Error('CI config not found')
  config

awaitEachProjectAndProvider = (fn) ->
  creds = getCiConfig()
  la(check.unemptyString(creds.githubToken), "missing githubToken")
  la(check.unemptyString(creds.circleToken), "missing circleToken")

  ## configure a new Bumpercar
  car = bumpercar.create({
    providers: {
      travis: {
        githubToken: creds.githubToken
      }
      circle: {
        circleToken: creds.circleToken
      }
    }
  })

  Promise.resolve()
  .then ->
    _.map PROVIDERS, (projects, provider) ->
      Promise.map projects, (project) ->
        fn(project, provider, creds)
  .all()

module.exports = {
  # in each project, set a couple of environment variables
  version: (nameOrUrl, binaryVersionOrUrl) ->
    la(check.unemptyString(nameOrUrl),
      "missing cypress name or url to set", nameOrUrl)

    if check.semver(nameOrUrl)
      console.log("for version", nameOrUrl)
      nameOrUrl = "cypress@#{nameOrUrl}"
      console.log("full NPM install name is", nameOrUrl)

    la(check.unemptyString(binaryVersionOrUrl),
      "missing binary version or url", binaryVersionOrUrl)

    result = {
      versionName: nameOrUrl,
      binary: binaryVersionOrUrl
    }

    updateProject = (project, provider) ->
      console.log("setting environment variables in", project)
      car.updateProjectEnv(project, provider, {
        CYPRESS_NPM_PACKAGE_NAME: nameOrUrl,
        CYPRESS_BINARY_VERSION: binaryVersionOrUrl
      })
    awaitEachProjectAndProvider(updateProject)
    .then R.always(result)

  run: (message) ->
    if not message
      message =
        """
        Testing new Cypress version

        CI build url #{process.env.CIRCLE_BUILD_URL}
        """
    awaitEachProjectAndProvider (project, provider, creds) ->
      # instead of triggering CI via API
      # car.runProject(project, provider)
      # make empty commit to trigger CIs

      parsedRepo = parse(project)
      console.log("running project", project)
      makeEmptyGithubCommit({
        owner: parsedRepo[0],
        repo: parsedRepo[1],
        token: creds.githubToken,
        message
      })
}
