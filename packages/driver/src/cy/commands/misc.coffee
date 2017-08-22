_ = require("lodash")

$Log = require("../../cypress/log")
$utils = require("../../cypress/utils")

module.exports = (Commands, Cypress, cy, state, config) ->
  Commands.addAll({ prevSubject: "optional" }, {
    end: ->
      null
  })

  Commands.addAll({
    noop: (arg) -> arg

    log: (msg, args) ->
      Cypress.log({
        end: true
        snapshot: true
        message: [msg, args]
        consoleProps: ->
          {
            message: msg
            args:    args
          }
      })

      return null

    wrap: (arg, options = {}) ->
      _.defaults options, {log: true}

      if options.log isnt false
        options._log = Cypress.log()

        if $utils.hasElement(arg)
          options._log.set({$el: arg})

      do resolveWrap = =>
        cy.verifyUpcomingAssertions(arg, options, {
          onRetry: resolveWrap
        })
  })
