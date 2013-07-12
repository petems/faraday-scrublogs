require 'spec_helper'
require 'logger'

describe Faraday::ScrubLogs::ScrubLogs do

  context 'Using faraday to call http://widgets.example.org/?client_id=ABCD123&api_key=123ABCD' do

    context ':scrub => false' do

      subject(:log) { io.read }

      before do
        perform_request
        io.rewind
      end

      let(:io) { StringIO.new }
      let(:logger) { Logger.new(io) }

      def perform_request
        connection.get("/test") do |request|
          request.headers["X-Foo"] = "bar"
          request.body = "the request body"
        end
      end

      def connection
        create_connection do |faraday|
          faraday.use :scrublogs, :logger => logger, :scrub => false
        end
      end

      it "includes the HTTP verb" do
        log.should include "GET"
      end

      it "includes the request body" do
        log.should include "the request body"
      end

      it "includes the request headers" do
        log.should match %r"X-Foo\s+: bar"
      end

      it "includes the complete URL" do
        log.should include "http://widgets.example.org/test"
      end

      it "does not scrub the logs of data" do
        log.should include "?client_id=ABCD123&api_key=123ABCD"
        log.should_not include "?client_id=[REDACTED]&api_key=[REDACTED]"
      end

      it "includes the response status" do
        log.should include "200"
      end

      it "includes the response time" do
        log.should match(/\d+\.\d+ms/)
      end

      it "includes the response headers" do
        log.should include "X-Bar : foo"
      end

      it "includes the response body" do
        log.should include "the response body"
      end

    end

    context ':scrub => [/client_id=[a-zA-z0-9]*/,/api_key=[a-zA-z0-9]*/]' do

      subject(:log) { io.read }

      before do
        perform_request
        io.rewind
      end

      let(:io) { StringIO.new }
      let(:logger) { Logger.new(io) }

      def perform_request
        connection.get("/test") do |request|
          request.headers["X-Foo"] = "bar"
          request.body = "the request body"
        end
      end

      def connection
        create_connection do |faraday|
          faraday.use :scrublogs, :logger => logger, :scrub => [/(client_id=)([a-zA-z0-9]*)/,/(api_key=)([a-zA-z0-9]*)/]
        end
      end

      it "includes the HTTP verb" do
        log.should include "GET"
      end

      it "includes the request body" do
        log.should include "the request body"
      end

      it "includes the request headers" do
        log.should match %r"X-Foo\s+: bar"
      end

      it "includes the complete URL" do
        log.should include "http://widgets.example.org/test"
      end

      it "scrubs the logs of data" do
        log.should include "?client_id=[REDACTED]&api_key=[REDACTED]"
        log.should_not include "?client_id=ABCD123&api_key=123ABCD"
      end

      it "includes the response status" do
        log.should include "200"
      end

      it "includes the response time" do
        log.should match(/\d+\.\d+ms/)
      end

      it "includes the response headers" do
        log.should include "X-Bar : foo"
      end

      it "includes the response body" do
        log.should include "the response body"
      end

    end

    context ':scrub => [/DONTFINDME/]' do

      subject(:log) { io.read }

      before do
        perform_request
        io.rewind
      end

      let(:io) { StringIO.new }
      let(:logger) { Logger.new(io) }

      def perform_request
        connection.get("/test") do |request|
          request.headers["X-Foo"] = "bar"
          request.body = "the request body"
        end
      end

      def connection
        create_connection do |faraday|
          faraday.use :scrublogs, :logger => logger, :scrub => [/DONTFINDME/]
        end
      end

      it "includes the HTTP verb" do
        log.should include "GET"
      end

      it "includes the request body" do
        log.should include "the request body"
      end

      it "includes the request headers" do
        log.should match %r"X-Foo\s+: bar"
      end

      it "includes the complete URL" do
        log.should include "http://widgets.example.org/test"
      end

      it "does not scrub the logs of data" do
        log.should_not include "DONTFINDME"
        log.should_not include "[REDACTED]"
      end

      it "includes the response status" do
        log.should include "200"
      end

      it "includes the response time" do
        log.should match(/\d+\.\d+ms/)
      end

      it "includes the response headers" do
        log.should include "X-Bar : foo"
      end

      it "includes the response body" do
        log.should include "the response body"
      end

    end

  end

end
