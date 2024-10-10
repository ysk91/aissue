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


### Code Generation via CLI Tool

Executing aissue start launches the CLI tool.
Initially, it prompts the user for the following three inputs:

- Purpose of the code to be created
- Data (optional)
- Path to the target script (optional)

If the path to the target script is not entered (or not found on the GitHub repository), it will create standalone code independent of the repository.
If the path to the target script is provided, it will propose modified code for that script.

If the script is not entered, it will ask whether to execute the created code.
At this time, **if the code poses no risks**, you can enter y to see the result.

Finally, you will be asked whether to log the created code as an issue.
Enter y to create an issue and display the URL.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ysk91/aissue. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/aissue/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aissue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ysk91/aissue/blob/main/CODE_OF_CONDUCT.md).
