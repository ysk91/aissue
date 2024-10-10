# Aissue



## Installation

Install the gem and add to the application's Gemfile by executing:

```
$ bundle add aissue
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
$ gem install aissue
```

### .env

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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ysk91/aissue. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/aissue/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aissue project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ysk91/aissue/blob/main/CODE_OF_CONDUCT.md).
