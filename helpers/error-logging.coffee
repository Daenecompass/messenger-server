if process.env.sentry_dsn
  raven = require 'raven'
  raven.config(process.env.sentry_dsn).install()

  module.exports = raven
