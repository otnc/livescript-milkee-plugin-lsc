fs = require 'fs'
path = require 'path'
consola = require 'consola'
child_process = require 'child_process'

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
    'inlineMap': '--inline-map'
    'inline-map': '--inline-map'
    noHeader: '--no-header'
    'no-header': '--no-header'
    literate: '--literate'
    watch: '--watch'
  map[key]

buildFlags = (options) ->
  flags = []
  keys = Object.keys options
  keys.forEach ((k) ->
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

runLsc = (output, entry, flags) ->
  args = ['lsc' '--output' output]
  args = args.concat(flags)
  args.push '--compile'
  args.push entry
  info "Running: npx #{args.join ' '}"

  proc = child_process.spawn('npx', args, {stdio: 'pipe'})

  proc.stdout.on('data', (data) ->
    s = data.toString().trim()
    if s isnt ''
      log s
  )

  proc.stderr.on('data', (data) ->
    s = data.toString().trim()
    if s isnt ''
      error s
  )

  new Promise (resolve, reject) ->
    # If spawning the process fails (e.g., 'npx' or 'lsc' not found)
    proc.on('error', (err) ->
      error "Failed to start 'npx lsc': #{err.message}"
      info "Install LiveScript to run 'lsc': `npm i -D livescript` or `npm i -g livescript`"
      reject err
    )

    proc.on('close', (code) ->
      if code is 0
        success "lsc finished (code #{code})"
        resolve()
      else
        err = new Error "lsc exited with code #{code}"
        error err.message
        info "If the 'lsc' command is not found or fails, install LiveScript: `npm i -D livescript` or `npm i -g livescript`"
        reject err
    )

module.exports = (pluginOptions = {}) ->
  (compilationResult) ->
    config = compilationResult.config or {}
    compiledFiles = compilationResult.compiledFiles or []

    info "Compiled #{compiledFiles.length} file(s)"
    for file in compiledFiles
      log "  - #{file}"

    output = config.output or pluginOptions.output or 'dist'
    entry = config.entry or pluginOptions.entry or 'src'
    options = config.options or {}

    flags = buildFlags options

    info "Triggering LiveScript compile: entry=#{entry} output=#{output} flags=#{flags.join ' '}"

    runLsc(output, entry, flags)
      .then ->
        success "LiveScript compile succeeded"
      .catch (err) ->
        error "LiveScript compile failed: #{err.message}"
        throw err


