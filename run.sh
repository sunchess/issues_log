#!/usr/bin/env ruby

require 'pathname'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile',
                                           Pathname.new(__FILE__).realpath)

require 'rubygems'
require 'bundler/setup'
require 'httparty'
require 'awesome_print'

require_relative 'issues_log'

ap IssuesLog::SupportIssues.new.get_issues.format
