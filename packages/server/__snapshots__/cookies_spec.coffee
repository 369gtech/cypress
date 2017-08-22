exports['e2e cookies passes 1'] = `Error: connect ECONNREFUSED 127.0.0.1:1234
 > The local API server isn't running in development. This may cause problems running the GUI.

-----------------------------------------------------------------------------------
You are using an older version of the CLI tools.

Please update the CLI tools by running: npm install -g cypress-cli
-----------------------------------------------------------------------------------

Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)


  cookies
    ✓ can get all cookies (123ms)
    ✓ resets cookies between tests correctly (123ms)
    ✓ should be only two left now
    ✓ sends cookies to localhost:2121 (123ms)
    ✓ handles expired cookies (123ms)
    ✓ issue: #224 sets expired cookies between redirects (123ms)


  6 passing (123ms)


  (Tests Finished)

  - Tests:           6
  - Passes:          6
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

