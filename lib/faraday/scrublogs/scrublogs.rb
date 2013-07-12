require 'forwardable'

module Faraday
  module ScrubLogs
    class ScrubLogs < Faraday::Middleware

      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal

      DEFAULT_OPTIONS = { :scrub => false }

      def initialize(app, options = {})
        @app = app
        @logger = options.fetch(:logger) {
          require 'logger'
          ::Logger.new($stderr)
        }
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def call(env)
        start_time = Time.now
        info  { request_info(env) }
        debug { request_debug(env) }
        @app.call(env).on_complete do
          end_time = Time.now
          response_time = end_time - start_time
          info  { response_info(env, response_time) }
          debug { response_debug(env) }
        end
      end

      private

      def scrub_logs?
        @options[:scrub]
      end

      def scrub_url(scrub_me)
        scrub_words = @options[:scrub]
        return_string = scrub_me.to_s
        if scrub_logs?
          scrub_words.each do | scrub_word |
            return_string = return_string.gsub(scrub_word,'\1[REDACTED]')
          end
        end
        return_string
      end

      def request_info(env)
        if scrub_logs?
          "Started %s request to: %s" % [ env[:method].to_s.upcase, scrub_url(env[:url]) ]
        else
          "Started %s request to: %s" % [ env[:method].to_s.upcase, env[:url] ]
        end
      end

      def response_info(env, response_time)
        if scrub_logs?
          "Response from %s; Status: %d; Time: %.1fms" % [ scrub_url(env[:url]), env[:status], (response_time * 1_000.0) ]
        else
          "Response from %s; Status: %d; Time: %.1fms" % [ env[:url], env[:status], (response_time * 1_000.0) ]
        end
      end

      def request_debug(env)
        debug_message("Request", env[:request_headers], env[:body])
      end

      def response_debug(env)
        debug_message("Response", env[:response_headers], env[:body])
      end

      def debug_message(name, headers, body)
        <<-MESSAGE.gsub(/^ +([^ ])/m, '\\1')
        #{name} Headers:
        ----------------
        #{format_headers(headers)}

        #{name} Body:
        -------------
        #{body}
        MESSAGE
      end

      def format_headers(headers)
        length = headers.map {|k,v| k.to_s.size }.max
        headers.map { |name, value| "#{name.to_s.ljust(length)} : #{value}" }.join("\n")
      end

    end
  end
end
