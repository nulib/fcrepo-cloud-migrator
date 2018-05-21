# Fcrepo::Cloud::Migrator

**Assumptions**
1. You have a local fcrepo that is 4.7.x or greater
1. This local fcrepo contains internal binaries
1. You have a AWS based fcrepo that is 4.7.x or greater
1. This AWS fcrepo is configured for [external binaries](https://wiki.duraspace.org/display/FEDORA4x/How+to+add+Use+Amazon+Simple+Scalable+Storage+%28S3%29+for+Storing+Fedora+Content)

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

###

1. Install [aws-cli](https://aws.amazon.com/cli/) and [configure your credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
1. Use [fcrepo-import-export](https://github.com/fcrepo4-labs/fcrepo-import-export) to export your repository with binaries.  This tool is currently tested against [version 0.2.0](https://github.com/fcrepo4-labs/fcrepo-import-export/releases/tag/fcrepo-import-export-0.2.0) of the tool.
1. Run `command TBD`, this will copy your files to s3 and modify your `.ttl` files to reference external binaries
1. Use the `fcrepo-import-export` tool with the flags `tbd` to import the modified ttl files into your AWS Fedora

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nulib/fcrepo-cloud-migrator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
