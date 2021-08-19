module IssuesLog
  class SupportIssues
    include HTTParty
    base_uri 'https://api.github.com/repos/Uscreen-video/issues'
    debug_output $stdout

    attr_reader :accumulator

    def initialize
      @labels = ENV['LABELS'] || ['API & Integrations ❄️', 'Marketing ❄️', 'North Team ❄️']
      @github_token = ENV['TOKEN']
      @accumulator = []
    end

    def get_issues
      @labels.each do |label|
        response = issues_by_label(label)
        @accumulator << JSON.parse(response.body)
      end

      @accumulator = @accumulator.flatten.uniq
      self
    end

    def format
      return if @accumulator.empty?

      @accumulator.map do |issue|
        {
          id: issue['number'],
          url: issue['html_url'],
          title: issue['title'],
          date: issue['created_at'],
          assignee: issue['assignees'].any? ? issue['assignees'].map { |i| i['login'] }.join(', ') : nil
        }
      end
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
