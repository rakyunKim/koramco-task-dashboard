require "net/http"

module Jira
  class Client
    BASE_PATH = "/rest/api/3"

    def initialize(setting = JiraSetting.current)
      @setting = setting
      @base_url = setting.site_url
    end

    def test_connection
      get("/myself")
      true
    rescue StandardError
      false
    end

    def get(path, params = {})
      request(:get, path, params: params)
    end

    def post(path, body = {})
      request(:post, path, body: body)
    end

    private

    def request(method, path, options = {})
      uri = URI("#{@base_url}#{BASE_PATH}#{path}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30

      req = build_request(method, uri, options)
      req.basic_auth(@setting.email, @setting.api_token)
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"

      response = http.request(req)
      handle_response(response)
    end

    def build_request(method, uri, options)
      case method
      when :get
        uri.query = URI.encode_www_form(options[:params]) if options[:params]&.any?
        Net::HTTP::Get.new(uri)
      when :post
        req = Net::HTTP::Post.new(uri)
        req.body = options[:body].to_json if options[:body]
        req
      end
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        JSON.parse(response.body.force_encoding("UTF-8")) if response.body.present?
      when 401
        raise Jira::AuthenticationError, "Jira 인증 실패"
      when 403
        raise Jira::ForbiddenError, "Jira 접근 권한 없음"
      when 429
        raise Jira::RateLimitError, "Jira API 요청 한도 초과"
      else
        raise Jira::ApiError, "Jira API 오류: #{response.code} - #{response.body&.force_encoding('UTF-8')}"
      end
    end
  end
end
