require "faraday"

require "faraday/scrublogs/version"

require "faraday/scrublogs/extended_logging"

module Faraday
  module ScrubLogs
  end
  register_middleware :middleware, :extended_logging => Faraday::ScrubLogs::ExtendedLogging
end

