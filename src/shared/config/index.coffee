mode = if process.env.NODE_ENV then process.env.NODE_ENV else "production"

try
  config = require "./#{mode}"
catch e
  console.error "could not load config for mode #{mode}"
  config = {}

module.exports = config
