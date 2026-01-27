
fs = require 'fs'
path = require 'path'
consola = require 'consola'

pkg = require '../package.json'
PREFIX = "[#{pkg.name}]"

# Simple, robust logger (avoid spread/computed props for compatibility)
log = (msg) -> consola.log "#{PREFIX} #{msg}"
info = (msg) -> consola.info "#{PREFIX} #{msg}"
success = (msg) -> consola.success "#{PREFIX} #{msg}"
warn = (msg) -> consola.warn "#{PREFIX} #{msg}"
error = (msg) -> consola.error "#{PREFIX} #{msg}"

getFlag = (key) ->
  map =
    bare: '--bare'
    join: '--join'
    map: '--map'
    inlineMap: '--inline-map'
    noHeader: '--no-header'
    literate: '--literate'
    # watch: '--watch'  # No longer supported
  map[key]

buildFlags = (options) ->
  flags = []
  keys = Object.keys options
  keys.forEach ((k) ->
    if k is 'watch'
      warn "'watch' option is ignored by milkee-plugin-lsc. Use an external watcher if needed."
    v = options[k]
    flag = getFlag k
    unless flag
      warn "Skipping unsupported LiveScript option: #{k}"
      return
    if typeof v is 'boolean'
      if v
        flags.push flag
    else
      flags.push flag
      flags.push "#{v}"
  )
  flags




# Compile all .ls files in ./src to ./dist using livescript and options
compileAll = (livescript, options = {}) ->
  unless livescript?
    error "livescript option is required. Please provide require('livescript')."
    throw new Error('livescript option is required')

  # 許可するLiveScriptオプション（watch以外）
  allowed = ['bare', 'map', 'inlineMap', 'noHeader', 'literate']
  compileOpts = {}
  for k, v of options
    if allowed.includes(k)
      compileOpts[k] = v
    else if k is 'watch'
      warn "'watch' option is ignored by milkee-plugin-lsc. Use an external watcher if needed."
    else
      warn "Skipping unsupported LiveScript option: #{k}"

  entry = 'src'
  output = 'dist'
  if !fs.existsSync(entry)
    warn "Entry directory not found: #{entry}"
    return Promise.resolve()
  files = fs.readdirSync(entry)
    .filter (f) -> /\.ls$/i.test(f)
    .map (f) -> path.join(entry, f)
  if files.length == 0
    warn "No .ls files found in entry: #{entry}"
    return Promise.resolve()
  if !fs.existsSync(output)
    fs.mkdirSync(output, {recursive: true})
  promises = files.map (file) ->
    src = fs.readFileSync(file, 'utf8')
    outFile = path.join(output, path.basename(file, '.ls') + '.js')
    try
      js = livescript.compile(src, compileOpts)
      fs.writeFileSync(outFile, js, 'utf8')
      success "Compiled #{file} -> #{outFile}"
    catch err
      error "Failed to compile #{file}: #{err.message}"
      throw err
  Promise.all(promises)

module.exports = (pluginOptions = {}) ->
  (compilationResult) ->
    opts = (compilationResult.config?.options) or {}
    info "Triggering LiveScript compile: src -> dist"
    compileAll(pluginOptions.livescript, opts)
      .then ->
        success "LiveScript compile succeeded"
      .catch (err) ->
        error "LiveScript compile failed: #{err.message}"
        throw err
