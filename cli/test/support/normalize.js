const stripAnsi = require('strip-ansi')

const excessWhitespaceRe = /(\s{3,})/
const datesRe = /(\d+:\d+:\d+)/g
const downloadQueryRe = /(\?platform=(darwin|linux|win32)&arch=(x64|ia32))/

module.exports = (str) => {
  // strip dates and ansi codes
  // and excess whitespace
  return stripAnsi(
    str
    .replace(datesRe, 'xx:xx:xx')
    .replace(excessWhitespaceRe, ' ')
    .replace(downloadQueryRe, '?platform=OS&arch=ARCH')
  )
}
