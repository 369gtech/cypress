const cheerio = require('cheerio')

function isInvalidId (id) {
  return typeof id === 'undefined' ||
    id === '' ||
    id === '#' ||
    id.startsWith('#-')
}

function addPageAnchors (str) {
  // use the htmlParser2 which does not add
  // <html><head><body to the resulting DOM
  // https://github.com/cheeriojs/cheerio/pull/1027/files

  // despite what cheerio says, it does wrap in <HTML>...
  // see unit tests :(
  const $ = cheerio.load(str, {
    useHtmlParser2: true,
    decodeEntities: false,
  })

  const $headings = $('h1, h2, h3, h4, h5, h6')

  if (!$headings.length) return str

  $headings.each(function () {
    const id = $(this).attr('id')

    if (isInvalidId(id)) {
      throw new Error(`Bad heading id ${id}
        in the section
        ${$.html()}
      `)
    }

    $(this)
      .addClass('article-heading')
      .append(`<a class="article-anchor" href="#${id}" aria-hidden="true"></a>`)
  })

  return $.html()
}

module.exports = {
  addPageAnchors,
}
