(->
  log = require('ko/logging').getLogger 'commando-recent-files'
  commando = require 'commando/commando'

  parseURI = (uri) =>
    path: ko.uriparse.URIToPath uri
    basename: ko.uriparse.baseName uri
    extension: ko.uriparse.ext uri

  @onSearch = (query, uuid, onComplete) =>
    log.debug "#{uuid} - Starting Scoped Search"
    results = []

    for file in ko.mru.getAll 'mruFileList'
      data = parseURI file
      results.push
        name: data.basename
        description: data.path
        uri: file
        allowExpand: no
        allowMultiSelect: on
        classList: 'small-icon'
        scope: 'scope-recent-files'
        icon: "koicon://#{window.encodeURIComponent data.basename}?size=14"

    query = query.toLowerCase()
    words = query.split ' '

    words = words.filter (w) => !!w

    if words
      results = results.filter (result) =>
        text = result.name.toLowerCase()
        if words.every((w) => text.indexOf(w) isnt -1)
          return on
        return no

    if results.length
      commando.renderResults results, uuid

    onComplete()

  @onSelectResult = (selected) =>
    uris = []
    for item in selected
      uris.push item.resultData.uri

    if uris.length is 1
      ko.open.URI uris[0]
    else
      ko.open.multipleURIs uris

    commando.hide()

).apply module.exports
