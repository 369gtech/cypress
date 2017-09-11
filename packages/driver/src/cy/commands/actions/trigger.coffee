_ = require("lodash")
Promise = require("bluebird")

{ waitForActionability, getPositionFromArguments } = require("./utils")
$dom = require("../../../dom")
$utils = require("../../../cypress/utils")

dispatch = (target, eventName, options) ->
  event = new Event(eventName, options)

  ## some options, like clientX & clientY, must be set on the
  ## instance instead of passing them into the constructor
  _.extend(event, options)

  target.dispatchEvent(event)

module.exports = (Commands, Cypress, cy, state, config) ->
  Commands.addAll({ prevSubject: ["element", "window", "document"] }, {
    trigger: (subject, eventName, positionOrX, y, options = {}) ->
      {options, position, x, y} = getPositionFromArguments(positionOrX, y, options)

      _.defaults(options, {
        log: true
        $el: subject
        bubbles: true
        cancelable: true
        position: position
        x: x
        y: y
        waitForAnimations: config("waitForAnimations")
        animationDistanceThreshold: config("animationDistanceThreshold")
      })

      ## omit entries we know aren't part of an event, but pass anything
      ## else through so user can specify what the event object needs
      eventOptions = _.omit(options, "log", "$el", "position", "x", "y", "waitForAnimations", "animationDistanceThreshold")

      if options.log
        options._log = Cypress.log({
          $el: subject
          consoleProps: ->
            {
              "Yielded": subject
              "Event options": eventOptions
            }
        })

        options._log.snapshot("before", {next: "after"})

      if not _.isString(eventName)
        $utils.throwErrByPath("trigger.invalid_argument", {
          onFail: options._log
          args: { eventName }
        })

      if options.$el.length > 1
        $utils.throwErrByPath("trigger.multiple_elements", {
          onFail: options._log
          args: { num: options.$el.length }
        })

      win = state("window")

      dispatchEarly = false

      ## if we're window or document then dispatch early
      ## and avoid waiting for actionability
      if $dom.isWindow(subject) or $dom.isDocument(subject)
        dispatchEarly = true
      else
        subject = options.$el.first()

      trigger = ->
        if dispatchEarly
          return dispatch(subject, eventName, eventOptions)

        waitForActionability(cy, subject, win, options, {
          onScroll: ($el, type) ->
            Cypress.action("cy:scrolled", $el, type)

          onReady: ($elToClick, coords) ->
            if options._log
              ## display the red dot at these coords
              options._log.set({coords: coords})

            eventOptions = _.extend({
              clientX: $utils.getClientX(coords, win)
              clientY: $utils.getClientY(coords, win)
              pageX: coords.x
              pageY: coords.y
            }, eventOptions)

            dispatch($elToClick.get(0), eventName, eventOptions)
      })

      Promise
      .try(trigger)
      .then ->
        do verifyAssertions = ->
          cy.verifyUpcomingAssertions(subject, options, {
            onRetry: verifyAssertions
          })
  })
