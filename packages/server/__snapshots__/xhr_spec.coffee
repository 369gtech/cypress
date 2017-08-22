exports['e2e xhr passes 1'] = `Error: connect ECONNREFUSED 127.0.0.1:1234
 > The local API server isn't running in development. This may cause problems running the GUI.

-----------------------------------------------------------------------------------
You are using an older version of the CLI tools.

Please update the CLI tools by running: npm install -g cypress-cli
-----------------------------------------------------------------------------------

Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)


  xhrs
    ✓ can encode + decode headers (123ms)
    ✓ ensures that request headers + body go out and reach the server unscathed (123ms)
    ✓ does not inject into json's contents from http server even requesting text/html (123ms)
    ✓ does not inject into json's contents from file server even requesting text/html (123ms)
    ✓ works prior to visit
    server with 1 visit
      ✓ response body (123ms)
      ✓ request body (123ms)
      ✓ aborts (123ms)


  8 passing (123ms)


  (Tests Finished)

  - Tests:           8
  - Passes:          8
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

