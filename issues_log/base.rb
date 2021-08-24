module IssuesLog
  class Base
    attr_reader :accumulator

    def initialize(slack_client = nil)
      @support_labels = ENV['SUPPORT_LABELS']&.split(',')&.map(&:strip) || ['API & Integrations ❄️', 'Marketing ❄️', 'North Team ❄️']
      @labels = ENV['LABELS']&.split(',')&.map(&:strip) || ['North Team :snowflake:']
      @github_token = ENV['GITHUB_TOKEN']
      @accumulator = []
      @slack_channel = ENV['CHANNEL']
      @slack_client = slack_client
    end

    def get_issues
      @support_labels.each do |label|
        response = issues_by_label(label)
        @accumulator << JSON.parse(response.body)
      end

      @accumulator = @accumulator.flatten.uniq
      self
    end

    private

    def issues_by_label(label)
      options = build_options(label)
      self.class.get("/issues", options)
    end

    def build_options(label)
      {
        query: { labels: label },
        headers: {
          'Authorization' => "token #{@github_token}",
        }
      }
    end
  end
end
