module IssuesLog
  class Base
    include HTTParty
    # debug_output $stdout

    attr_reader :accumulator

    def initialize(slack_client = nil)
      @support_labels = ENV['SUPPORT_LABELS']&.split(',')&.map(&:strip) || ['API :unicorn:', 'Analytics 🦄', 'Customization 🦄', 'Live Events 🦄', 'Content 👽 🦄']
      @labels = ENV['LABELS']&.split(',')&.map(&:strip) || ['Viana Team :unicorn:']
      @github_token = ENV['GITHUB_TOKEN']
      @accumulator = []
      @slack_channel = ENV['CHANNEL']
      @slack_client = slack_client
    end

    private

    def issues_by_label(label)
      options = build_options(label)
      self.class.get("/issues", options)
    end

    def build_options(label)
      {
        query: {
          labels: label,
          sort: 'updated'
        },
        headers: {
          'Authorization' => "token #{@github_token}",
        }
      }
    end
  end
end
