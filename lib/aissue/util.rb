require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'dotenv/load'
require 'octokit'

module Aissue
  class << self
    def client
      @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    end

    def repository
      ENV['GITHUB_OWNER'] + '/' + ENV['REPOSITORY']
    end
  end

  module Util
    # OpenAI API
    def post_openai(prompt, model: ENV['GPT_MODEL'], temperature: 0.7, json: false)
      data = {
        model: model,
        messages: [{"role" => "user", "content" => prompt}],
        temperature: temperature
      }

      data["response_format"] = {"type" => "json_object"} if json

      uri = URI.parse("https://api.openai.com/v1/chat/completions")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
      request.body = data.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      response_body = JSON.parse(response.body)
      content = response_body["choices"][0]["message"]["content"] if response_body

      if content
        json ? JSON.parse(content) : content
      end
    end

    # GitHub API
    def get_file_contents(path, base_path = nil)
      full_path = base_path ? "#{base_path}/#{path}" : path

      begin
        file_content = Aissue.client.contents(Aissue.repository, path: full_path)
        decoded_content = Base64.decode64(file_content[:content]).force_encoding('UTF-8')
        { full_path => decoded_content }
      rescue Octokit::NotFound
        puts "Skipping #{full_path} (not found in repo)"
        nil
      rescue => e
        puts "Error retrieving #{full_path}: #{e}"
        nil
      end
    end

    def create_issue(title, body)
      issue = Aissue.client.create_issue(Aissue.repository, title, body)
      puts "Issue created: #{issue[:html_url]}"
    end
  end
end
