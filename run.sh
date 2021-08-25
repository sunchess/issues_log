#!/usr/bin/env ruby

require 'pathname'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', Pathname.new(__FILE__).realpath)

require 'rubygems'
require 'bundler/setup'
require 'httparty'
require 'awesome_print'
require 'slack-ruby-client'

$LOAD_PATH.push __dir__

require 'issues_log'

# slack gem config
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new
client.auth_test

IssuesLog::SupportIssues.new(client).get_issues.format!.send_message
IssuesLog::PullRequests.new(client).get_prs.format!.send_message
IssuesLog::Issues.new(client).get_issues.format!.send_message


