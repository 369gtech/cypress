exports['e2e web security when enabled fails 1'] = `Error: connect ECONNREFUSED 127.0.0.1:1234
 > The local API server isn't running in development. This may cause problems running the GUI.

-----------------------------------------------------------------------------------
You are using an older version of the CLI tools.

Please update the CLI tools by running: npm install -g cypress-cli
-----------------------------------------------------------------------------------

Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)


  web security
    1) fails when clicking <a> to another origin
    2) fails when submitted a form and being redirected to another origin
    3) fails when using a javascript redirect to another origin


  0 passing (123ms)
  3 failing

  1) web security fails when clicking <a> to another origin:
     CypressError: Cypress detected a cross origin error happened on page load:

  > Blocked a frame with origin "http://localhost:5566" from accessing a cross-origin frame.

Before the page load, you were bound to the origin policy:
  > http://localhost:5566

A cross origin error happens when your application navigates to a new superdomain which does not match the origin policy above.

This typically happens in one of three ways:

1. You clicked an <a> that routed you outside of your application
2. You submitted a form and your server redirected you outside of your application
3. You used a javascript redirect to a page outside of your application

Cypress does not allow you to change superdomains within a single test.

You may need to restructure some of your test code to avoid this problem.

Alternatively you can also disable Chrome Web Security which will turn off this restriction by setting { chromeWebSecurity: false } in your 'cypress.json' file.

https://on.cypress.io/cross-origin-violation

      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line

  2) web security fails when submitted a form and being redirected to another origin:
     CypressError: Cypress detected a cross origin error happened on page load:

  > Blocked a frame with origin "http://localhost:5566" from accessing a cross-origin frame.

Before the page load, you were bound to the origin policy:
  > http://localhost:5566

A cross origin error happens when your application navigates to a new superdomain which does not match the origin policy above.

This typically happens in one of three ways:

1. You clicked an <a> that routed you outside of your application
2. You submitted a form and your server redirected you outside of your application
3. You used a javascript redirect to a page outside of your application

Cypress does not allow you to change superdomains within a single test.

You may need to restructure some of your test code to avoid this problem.

Alternatively you can also disable Chrome Web Security which will turn off this restriction by setting { chromeWebSecurity: false } in your 'cypress.json' file.

https://on.cypress.io/cross-origin-violation

      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line

  3) web security fails when using a javascript redirect to another origin:
     CypressError: Cypress detected a cross origin error happened on page load:

  > Blocked a frame with origin "http://localhost:5566" from accessing a cross-origin frame.

Before the page load, you were bound to the origin policy:
  > http://localhost:5566

A cross origin error happens when your application navigates to a new superdomain which does not match the origin policy above.

This typically happens in one of three ways:

1. You clicked an <a> that routed you outside of your application
2. You submitted a form and your server redirected you outside of your application
3. You used a javascript redirect to a page outside of your application

Cypress does not allow you to change superdomains within a single test.

You may need to restructure some of your test code to avoid this problem.

Alternatively you can also disable Chrome Web Security which will turn off this restriction by setting { chromeWebSecurity: false } in your 'cypress.json' file.

https://on.cypress.io/cross-origin-violation

      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line
      at stack trace line




  (Tests Finished)

  - Tests:           3
  - Passes:          0
  - Failures:        3
  - Pending:         0
  - Duration:        10 seconds
  - Screenshots:     3
  - Video Recorded:  true
  - Cypress Version: 1.2.3


  (Screenshots)

  - /foo/bar/.projects/e2e/cypress/screenshots/web security -- fails when clicking a to another origin.png (1280x720)
  - /foo/bar/.projects/e2e/cypress/screenshots/web security -- fails when submitted a form and being redirected to another origin.png (1280x720)
  - /foo/bar/.projects/e2e/cypress/screenshots/web security -- fails when using a javascript redirect to another origin.png (1280x720)


  (Video)

  - Started processing:   Compressing to 32 CRF
  - Finished processing:  /foo/bar/.projects/e2e/cypress/videos/abc123.mp4 (0 seconds)


  (All Done)

`

exports['e2e web security when disabled fails 1'] = `Error: connect ECONNREFUSED 127.0.0.1:1234
 > The local API server isn't running in development. This may cause problems running the GUI.

-----------------------------------------------------------------------------------
You are using an older version of the CLI tools.

Please update the CLI tools by running: npm install -g cypress-cli
-----------------------------------------------------------------------------------

Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)


  web security
    ✓ fails when clicking <a> to another origin (123ms)
    ✓ fails when submitted a form and being redirected to another origin (123ms)
    ✓ fails when using a javascript redirect to another origin (123ms)


  3 passing (123ms)


  (Tests Finished)

  - Tests:           3
  - Passes:          3
  - Failures:        0
  - Pending:         0
  - Duration:        10 seconds
  - Screenshots:     0
  - Video Recorded:  true
  - Cypress Version: 1.2.3


  (Video)

  - Started processing:   Compressing to 32 CRF
  - Finished processing:  /foo/bar/.projects/e2e/cypress/videos/abc123.mp4 (0 seconds)


  (All Done)

`

