require "faraday"

require "faraday/scrublogs/version"

require "faraday/scrublogs/scrublogs"

module Faraday
  module ScrubLogs
  end
  register_middleware :middleware, :scrublogs => Faraday::ScrubLogs::ScrubLogs
end

