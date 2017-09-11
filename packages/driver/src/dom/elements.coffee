_ = require("lodash")
$ = require("jquery")
$jquery = require("./jquery")
$window = require("./window")
$document = require("./document")

fixedOrStickyRe = /(fixed|sticky)/

focusable = "a[href],link[href],button,input,select,textarea,[tabindex],[contenteditable]"

isElement = (obj) ->
  try
    !!(obj and obj[0] and _.isElement(obj[0])) or _.isElement(obj)
  catch
    false

isFocusable = ($el) ->
  $el.is(focusable)

isType = ($el, type) ->
  ($el.attr("type") or "").toLowerCase() is type

isScrollOrAuto = (prop) ->
  prop is "scroll" or prop is "auto"

isAncestor = ($el, $maybeAncestor) ->
  $el.parents().index($maybeAncestor) >= 0

isSelector = ($el, selector) ->
  $el.is(selector)

isDetached = ($el) ->
  not isAttached($el)

isAttached = ($el) ->
  ## if we're being given window
  ## then these are automaticallyed attached
  if $window.isWindow($el)
    ## there is a code path when forcing focus and
    ## blur on the window where this check is necessary.
    return true

  ## if this is a document we can simply check
  ## whether or not it has a defaultView (window).
  ## documents which are part of stale pages
  ## will have this property null'd out
  if $document.isDocument($el)
    return $document.hasActiveWindow($el)

  ## normalize into an array
  els = [].concat($jquery.unwrap($el))

  ## we could be passed an empty array here
  ## which in that case it is not attached
  if els.length is 0
    return false

  ## get the document from the first element
  doc = $document.getDocumentFromElement(els[0])

  ## TODO: i guess its possible each element
  ## is technically bound to a differnet document
  ## but c'mon
  isIn = (el) ->
    $.contains(doc, el)

  ## make sure the document is currently
  ## active (it has a window) and
  ## make sure every single element
  ## is attached to this document
  return $document.hasActiveWindow(doc) and _.every(els, isIn)

isTextLike = ($el) ->
  sel = (selector) -> isSelector($el, selector)
  type = (type) -> isType($el, type)

  _.some([
    sel("textarea")
    sel(":text")
    sel("[contenteditable]")
    type("password")
    type("email")
    type("number")
    type("date")
    type("week")
    type("month")
    type("time")
    type("datetime")
    type("datetime-local")
    type("search")
    type("url")
    type("tel")
  ])

isScrollable = ($el) ->
  checkDocumentElement = (win, documentElement) ->
    ## Check if body height is higher than window height
    return true if win.innerHeight < documentElement.scrollHeight

    ## Check if body width is higher than window width
    return true if win.innerWidth < documentElement.scrollWidth

    ## else return false since the window is not scrollable
    return false

  ## if we're the window, we want to get the document's
  ## element and check its size against the actual window
  switch
    when $window.isWindow($el)
      win = $el

      checkDocumentElement(win, win.document.documentElement)
    else
      ## if we're any other element, we do some css calculations
      ## to see that the overflow is correct and the scroll
      ## area is larger than the actual height or width
      el = $el[0]

      {overflow, overflowY, overflowX} = window.getComputedStyle(el)

      ## y axis
      ## if our content height is less than the total scroll height
      if el.clientHeight < el.scrollHeight
        ## and our element has scroll or auto overflow or overflowX
        return true if isScrollOrAuto(overflow) or isScrollOrAuto(overflowY)

      ## x axis
      if el.clientWidth < el.scrollWidth
        return true if isScrollOrAuto(overflow) or isScrollOrAuto(overflowX)

      return false

isDescendent = ($el1, $el2) ->
  return false if not $el2

  !!(($el1.get(0) is $el2.get(0)) or $el1.has($el2).length)

getFirstFixedOrStickyPositionParent = ($el) ->
  ## return null if we're at body/html
  ## cuz that means nothing has fixed position
  return null if not $el or $el.is("body,html")

  ## if we have fixed position return ourselves
  if fixedOrStickyRe.test($el.css("position"))
    return $el

  ## else recursively continue to walk up the parent node chain
  getFirstFixedOrStickyPositionParent($el.parent())

getFirstScrollableParent = ($el) ->
  # doc = $el.prop("ownerDocument")

  # win = getWindowFromDoc(doc)

  ## this may be null or not even defined in IE
  # scrollingElement = doc.scrollingElement

  search = ($el) ->
    $parent = $el.parent()

    ## we have no more parents
    if not ($parent or $parent.length)
      return null

    ## we match the scrollingElement
    # if $parent[0] is scrollingElement
    #   return $parent

    ## instead of fussing with scrollingElement
    ## we'll simply return null here and let our
    ## caller deal with situations where they're
    ## needing to scroll the window or scrollableElement
    if $parent.is("html,body") or $document.isDocument($parent)
      return null

    if isScrollable($parent)
      return $parent

    return search($parent)

  return search($el)

positionProps = ($el, adjustments = {}) ->
  el = $el[0]

  return {
    width: el.offsetWidth
    height: el.offsetHeight
    top: el.offsetTop + (adjustments.top or 0)
    right: el.offsetLeft + el.offsetWidth
    bottom: el.offsetTop + el.offsetHeight
    left: el.offsetLeft + (adjustments.left or 0)
    scrollTop: el.scrollTop
    scrollLeft: el.scrollLeft
  }

getElements = ($el) ->
  return if not $el?.length

  ## unroll the jquery object
  els = $jquery.unwrap($el)

  if els.length is 1
    els[0]
  else
    els

## short form css-inlines the element
## long form returns the outerHTML
stringify = (el, form = "long") ->
  ## if we are formatting the window object
  if $window.isWindow(el)
    return "<window>"

  ## if we are formatting the document object
  if $document.isDocument(el)
    return "<document>"

  ## convert this to jquery if its not already one
  $el = $jquery.wrap(el)

  switch form
    when "long"
      text     = _.chain($el.text()).clean().truncate({length: 10 }).value()
      children = $el.children().length
      str      = $el.clone().empty().prop("outerHTML")
      switch
        when children then str.replace("></", ">...</")
        when text     then str.replace("></", ">#{text}</")
        else
          str
    when "short"
      str = $el.prop("tagName").toLowerCase()
      if id = $el.prop("id")
        str += "#" + id

      ## using attr here instead of class because
      ## svg's return an SVGAnimatedString object
      ## instead of a normal string when calling
      ## the property 'class'
      if klass = $el.attr("class")
        str += "." + klass.split(/\s+/).join(".")

      ## if we have more than one element,
      ## format it so that the user can see there's more
      if $el.length > 1
        "[ <#{str}>, #{$el.length - 1} more... ]"
      else
        "<#{str}>"


module.exports = {
  isType

  isElement

  isSelector

  isScrollOrAuto

  isFocusable

  isAttached

  isDetached

  isAncestor

  isScrollable

  isTextLike

  isDescendent

  stringify

  positionProps

  getElements

  getFirstFixedOrStickyPositionParent

  getFirstScrollableParent
}
