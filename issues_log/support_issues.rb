module IssuesLog
  class SupportIssues < Base
    include HTTParty
    base_uri 'https://api.github.com/repos/Uscreen-video/issues'
    #debug_output $stdout

    def format!
      return if @accumulator.empty?

      @accumulator.map! do |issue|
        pr_link = pull_request_link(issue['number'])

        {
          id: issue['number'],
          url: issue['html_url'],
          title: issue['title'],
          date: issue['created_at'],
          assignee: issue['assignees']&.any? ? issue['assignees'].map { |i| i['login'] }.join(', ') : nil,
          pr: pr_link
        }
      end

      self
    end

    def send_message
      count = @accumulator.count

      text = "Hey team, some statistics are below 📈 \n\n"
      text << "*Support issues* \n\n"
      text << case count
              when 0
                "Perfect! There is no support issues 🎉 \n"
              when 1
                "Awesome! Only *1* support issue ❤️ \n"
              when 2...20
                "Good job team! There are only *#{count}* support issues 💪 \n"
              when 20..50
                "Pull devil! There are *#{count}* support issues 🚀 \n "
              else
                "There are *#{count}* support issues. No pains, no gains 🏋️  \n "
              end

      text << "\n"
      text << @accumulator.map do |i|
        pr_link = i[:pr].nil? ? "*`No linked PR`*" : "<#{i[:pr]}|*PR link*>"

        "[#{i[:id]}] <#{i[:url]}|#{i[:title]}> - #{DateTime.parse(i[:date]).strftime('%D')} - #{pr_link} - *#{i[:assignee] || '`None`'}*  "
      end.join("\n")

      @slack_client.chat_postMessage(channel: @slack_channel , text: text, as_user: true) if @slack_channel

      text
    end

    private

    def pull_request_link(id)
      pr = pull_requests.find { |i| i['body'].include?("Uscreen-video/issues##{id}")}
      pr&.dig('pull_request', 'html_url')
    end

    def pull_requests
      @pull_requests ||= PullRequests.new.get_prs.accumulator
    end
  end
end
