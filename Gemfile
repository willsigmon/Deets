# Gemfile for Fastlane and Ruby dependencies
source "https://rubygems.org"

# Fastlane for iOS automation
gem "fastlane", "~> 2.220"

# Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# Code coverage
gem "slather", "~> 2.8"

# Testing
gem "xcpretty", "~> 0.3"
gem "xcpretty-travis-formatter", "~> 1.0"

# Code signing
gem "sigh", "~> 2.220"
gem "match", "~> 2.220"

# App Store Connect
gem "pilot", "~> 2.220"
gem "deliver", "~> 2.220"

# Screenshots
gem "snapshot", "~> 2.220"
gem "frameit", "~> 2.220"

# Utilities
gem "dotenv", "~> 2.8"
gem "bundler", "~> 2.5"
