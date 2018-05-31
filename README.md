# FcrepoCloudMigrator

[![Build Status](https://travis-ci.com/nulib/fcrepo-cloud-migrator.svg?branch=master)](https://travis-ci.com/nulib/fcrepo-cloud-migrator)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fcrepo-cloud-migrator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fcrepo-cloud-migrator

## Usage

### Step-By-Step

1. Install [aws-cli](https://aws.amazon.com/cli/) and [configure your credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
1. Use [fcrepo-import-export](https://github.com/fcrepo4-labs/fcrepo-import-export) to export your repository with binaries.  This tool is currently tested against [version 0.2.0](https://github.com/fcrepo4-labs/fcrepo-import-export/releases/tag/fcrepo-import-export-0.2.0) of the tool.
1. Create an empty Amazon S3 bucket.
1. Copy the contents of your export directory to the S3 bucket you just created (e.g., using `aws s3 sync`).
1. Run `bin/migrate <s3_bucket> <source_repo_url> <destination_repo_url>`.

### Simulated Run

Setting the environment variable `DRY_RUN=true` will make the migrator go through the motions without actually making any calls to Fedora.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nulib/fcrepo-cloud-migrator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
