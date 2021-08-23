module IssuesLog
  class SupportIssues
    include HTTParty
    base_uri 'https://api.github.com/repos/Uscreen-video/issues'
    debug_output $stdout

    attr_reader :accumulator

    def initialize(slack_client)
      @labels = ENV['LABELS'] || ['API & Integrations ❄️', 'Marketing ❄️', 'North Team ❄️']
      @github_token = ENV['GITHUB_TOKEN']
      @accumulator = []
      @slack_channel = ENV['CHANNEL']
      @slack_client = slack_client
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

      @accumulator.map! do |issue|
        {
          id: issue['number'],
          url: issue['html_url'],
          title: issue['title'],
          date: issue['created_at'],
          assignee: issue['assignees']&.any? ? issue['assignees'].map { |i| i['login'] }.join(', ') : nil
        }
      end

      self
    end

    def send_message
      count = @accumulator.count

      text = "Hey team, some statistics are below 📈 \n\n"
      text << "*Support issues* \n\n"
      text << case count
              when 1
                "Awesome only 1 issue ❤️  \n"
              when 2...20
                "Good job team! There are only #{count} issues 💪  \n"
              when 20..50
                "Pull devil! There are #{count} issues 🚀  \n "
              else
                "There are #{count} issues. No pains, no gains 🏋️  \n "
              end

      text << "\n"
      text << @accumulator.map do |i|
        "#{i[:id]} - <#{i[:url]}|#{i[:title]}> - #{DateTime.parse(i[:date]).strftime('%D')} - *#{i[:assignee] || '`None`'}*"
      end.join("\n")

      @slack_client.chat_postMessage(channel: @slack_channel , text: text, as_user: true)
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
