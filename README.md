# Aissue

Aissue is a tool that utilizes generative AI to provide a code creation CLI and a feature to log the causes and solutions of errors as issues.

By using the Aissue gem, you gain the following two benefits:

- Speed up handling of issues by checking the causes and solutions in the issues logged.
- Increase development speed by referencing automatically generated code.

## Installation

### Install Aissue gem

Install the gem and add to the application's Gemfile by executing:

```
$ bundle add aissue
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
$ gem install aissue
```

### create .env

Create a `.env` file in the root of the project and add the following:

```
OPENAI_API_KEY=sk-xxx
GPT_MODEL=gpt-4o-mini

GITHUB_TOKEN=ghp_xxx
GITHUB_OWNER=your-github-username
REPOSITORY=your-repository-name
AISSUE_LANG=if-you-want-to-specify-the-language(default: ja)
```

get your API Keys from here:
- OPENAI_API_KEY
  - https://platform.openai.com/settings/profile?tab=api-keys
- GITHUB_TOKEN
  - https://github.com/settings/tokens

## Usage

### Creating Issues on Error

By inserting `Aissue::Issue.rescue(e)` in the rescue block of a begin/rescue structure, you can analyze the cause and solution based on the error and create an issue.

For example, you can use it as follows:

```ruby
begin
  100 / 0 # Process where an error might occur
rescue
  Aissue::Issue.rescue(e)
end
```

The `rescue(e)` method outputs the issue URL as a return value, making it easier to notice errors when combined with Slack notifications.

#### ToDo

Currently, the code suggested here does not critically address the points where errors occur.
In my opinion, this issue is expected to be resolved by using the forthcoming publicly available o1 model.

### Code Generation via CLI Tool

Executing `aissue start` launches the CLI tool.
Initially, it prompts the user for the following three inputs:

- Requirements of the code to be created
- Data (optional)
- Path to the target script (optional)

If the path to the target script is not entered (or not found on the GitHub repository), it will create standalone code independent of the repository.
After create code, it will ask whether to execute the created code.
At this time, **if the code poses no risks**, you can enter y to see the result.

If the path to the target script is provided, it will propose modified code for that script.

Finally, you will be asked whether to log the created code as an issue.
Enter y to create an issue and display the URL.

#### Example

**without target script**

```shell
% aissue start
Please enter your requirements: 配列の中身をすべて大文字にし、実行するたびに順番をシャッフルする関数を作りたい
Please enter the relevant data: ['dog', 'cat', 'bird']
Please enter the path of the target script:
def shuffle_and_upcase(array)
  array.map(&:upcase).shuffle
end

result = shuffle_and_upcase(['dog', 'cat', 'bird'])
result
Do you want to run this code?(y/n): y
[WARNING] Attempted to create command "shuffle_and_upcase" without usage or description. Call desc if you want this method to be available as command or declare it inside a no_commands{} block. Invoked from "/Users/yusukesonoki/work_mine/aissue/lib/aissue/cli.rb:57:in `start'".
["BIRD", "CAT", "DOG"]
Would you like to record this code in a GitHub Issue?(y/n): y
https://github.com/ysk91/aissue/issues/10
```

After executing the created code, a message starting with `[WARNING] Attempted to create command` may be displayed.
This occurs when using a function not declared within the disc, and it is dependent on Thor.
While it does not affect usage, if you know of a better approach, we welcome your suggestions via a pull request.

**with target script**

```shell
% aissue start
Please enter your requirements: post_openaiの引数からjsonを削除し、常にJSONモードで使用したい
Please enter the relevant data:
Please enter the path of the target script: lib/aissue/util.rb
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
    def post_openai(prompt, model: ENV['GPT_MODEL'], temperature: 0.7)
      data = {
        model: model,
        messages: [{"role" => "user", "content" => prompt}],
        temperature: temperature
      }

      data["response_format"] = {"type" => "json_object"}

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

      content if content
    end

    # GitHub API
    def get_file_contents(path, base_path: nil)
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

    def record_issue(purpose, ruby_code, script_path: nil)
      issue_title = purpose
      issue_body = <<~BODY
        ## 対象スクリプト
        #{script_path}

        ## 実装コード
        ```ruby
        #{ruby_code}
        ```
      BODY

      create_issue(issue_title, issue_body)
    end
  end
end
Would you like to record this code in a GitHub Issue?(y/n): y
https://github.com/ysk91/aissue/issues/11
```

For those of you using AI for programming, you might already know that it can be risky to take the generated code at face value.
Please make sure to review the code thoroughly before implementing it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ysk91/aissue. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/aissue/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aissue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ysk91/aissue/blob/main/CODE_OF_CONDUCT.md).
