exports['e2e reporters reports error if cannot load reporter 1'] = `Could not load reporter by name module-does-not-exist
Relative to the project path /foo/bar/.projects/e2e

Learn more at stack trace line
`

exports['e2e reporters supports junit reporter and reporter options 1'] = `
Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)

  (Tests Finished)

  - Tests:           1
  - Passes:          1
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

exports['e2e reporters supports local custom reporter 1'] = `
Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)
passes
finished!

  (Tests Finished)

  - Tests:           undefined
  - Passes:          undefined
  - Failures:        undefined
  - Pending:         undefined
  - Duration:        10 seconds
  - Screenshots:     0
  - Video Recorded:  true
  - Cypress Version: 1.2.3


  (Video)

  - Started processing:   Compressing to 32 CRF
  - Finished processing:  /foo/bar/.projects/e2e/cypress/videos/abc123.mp4 (0 seconds)


  (All Done)

`

exports['e2e reporters supports npm custom reporter 1'] = `
Started video recording: /foo/bar/.projects/e2e/cypress/videos/abc123.mp4

  (Tests Starting)
[mochawesome] Generating report files...



  simple passing spec
    ✓ passes


  1 passing


[mochawesome] Report saved to mochawesome-reports/mochawesome.html



  (Tests Finished)

  - Tests:           1
  - Passes:          1
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
