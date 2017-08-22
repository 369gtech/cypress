cp        = require("child_process")
e2e      = require("../support/helpers/e2e")
Fixtures = require("../support/helpers/fixtures")
fs       = require("fs-extra")
path     = require("path")
Promise  = require("bluebird")

fs       = Promise.promisifyAll(fs)
e2ePath  = Fixtures.projectPath("e2e")

describe "e2e reporters", ->
  e2e.setup({npmInstall: true})

  it "reports error if cannot load reporter", ->
    e2e.exec(@, {
      spec: "simple_passing_spec.coffee"
      snapshot: true
      expectedExitCode: 1
      reporter: "module-does-not-exist"
    })

  it "supports junit reporter and reporter options", ->
    e2e.exec(@, {
      spec: "simple_passing_spec.coffee"
      expectedExitCode: 0
      snapshot: true
      reporter: "junit"
      reporterOptions: "mochaFile=junit-output/result.xml"
    })
    .then ->
      fs.readFileAsync(path.join(e2ePath, "junit-output", "result.xml"), "utf8")
      .then (str) ->
        expect(str).to.include("<testsuite name=\"simple passing spec\"")
        expect(str).to.include("<testcase name=\"simple passing spec passes\"")

  it "supports local custom reporter", ->
    e2e.exec(@, {
      spec: "simple_passing_spec.coffee"
      snapshot: true
      expectedExitCode: 0
      reporter: "reporters/custom.js"
    })

  it "supports npm custom reporter", ->
    e2e.exec(@, {
      spec: "simple_passing_spec.coffee"
      snapshot: true
      expectedExitCode: 0
      reporter: "mochawesome"
    })
    .then ->
      fs.readFileAsync(path.join(e2ePath, "mochawesome-reports", "mochawesome.html"), "utf8")
    .then (xml) ->
      expect(xml).to.include("<h3 class=\"suite-title\">simple passing spec</h3>")
      expect(xml).to.include("<div class=\"status-item status-item-passing-pct success\">100% Passing</div>")
