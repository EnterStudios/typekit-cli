# typekit-cli
A command line interface to use in managing your font kits at https://typekit.com.

Once you [sign up](https://accounts.adobe.com/) for an Adobe account, you can obtain an API token [here](https://typekit.com/account/tokens).

## Installation
If you have checked out the code from this repository, you can interact with the interface by typing the following on your command line in the root of your checked out code:
```
./bin/typekit
```

If you would like to install this as a gem you can install it via:
```
gem build typekit-cli.gemspec
gem install typekit-<version>.gem
```

## Usage

  Option                        | Description
  ------------------------------|--------------------------------------------------
  `logout`                      | Removes your cached Adobe Typekit API token
  `list`                        | Lists available kits associated with your account
  `create --domains=1 2 3 --name=NAME`  | Creates a kit using the specified name and domain list
  `publish --id=ID`             | Publish the specified kit publicly
  `remove --id=ID`              | Remove the specified kit
  `show --id=ID`                | Display detailed information about the specified kit

## Testing
Unit tests are written with [rspec](https://github.com/rspec/rspec) and can be run with the command `bundle exec rspec`

## Contributing
1. Fork it ( https://github.com/ascendantlogic/typekit-cli/fork )
1. Create your feature branch: `git checkout -b feature/new_feature`
1. Commit your changes: `git commit -am 'Add some cool stuff'`
1. Add test coverage in the spec directory
1. Run `bundle exec rspec` and ensure that all tests pass
1. Push to the branch: `git push origin feature/new_feature`
1. Create a new Pull Request
