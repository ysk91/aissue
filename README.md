# Aissue

日本語訳: https://qiita.com/ysk91_engineer/items/18127af3d2bd25645593

Aissue is a tool that utilizes generative AI to provide a code creation CLI and a feature to log the causes and solutions of errors as issues.

By using the Aissue gem, you gain the following two benefits:

- Speed up handling of issues by checking the causes and solutions in the issues logged.
- Increase development speed by referencing automatically generated code.

RubyGem: https://rubygems.org/gems/aissue

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
rescue => e
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
aissue_test % aissue start
Please enter your requirements: クラス化し、内部の処理を関数化。引数を分母にする
Please enter the relevant data:
Please enter the path of the target script: test.rb
class Division
  def initialize(numerator)
    @numerator = numerator
  end

  def divide(denominator)
    puts 'ゼロ除算します'
    begin
      @numerator / denominator
    rescue ZeroDivisionError => e
      handle_error(e)
    end
  end

  private

  def handle_error(exception)
    # エラーハンドリングの処理をここに記述
    "エラーが発生しました: #{exception.message}"
  end
end

division = Division.new(100)
result = division.divide(0)
result
Would you like to record this code in a GitHub Issue?(y/n): y
https://github.com/ysk91/aissue_test/issues/4
```

For those of you using AI for programming, you might already know that it can be risky to take the generated code at face value.
Please make sure to review the code thoroughly before implementing it.

## Development

- Ruby version >= 2.6.0

```
git clone git@github.com:ysk91/aissue.git
bundle install
bundle exec bin/aissue start
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ysk91/aissue. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ysk91/aissue/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aissue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ysk91/aissue/blob/main/CODE_OF_CONDUCT.md).
