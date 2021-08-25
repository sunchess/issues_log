module IssuesLog
  class PullRequests < Base
    base_uri 'https://api.github.com/repos/Uscreen-video/uscreen_2'

    def get_prs
      @labels.each do |label|
        response = issues_by_label(label)
        @accumulator << JSON.parse(response.body)
      end

      @accumulator = @accumulator.flatten.uniq.select { |i| i['pull_request'] }
      self
    end


    def format!
      return if @accumulator.empty?

      @accumulator.map! do |issue|
        {
          id: issue['number'],
          url: issue['pull_request']['html_url'],
          title: issue['title'],
          date: issue['created_at'],
          assignee: issue['assignees']&.any? ? issue['assignees'].map { |i| i['login'] }.join(', ') : nil
        }
      end

      self
    end

    def send_message
      count = @accumulator.count

      text = "*Pull requests* \n\n"
      text << "There are *#{count}* pull requests ⚙️ \n\n"

      text << @accumulator.map do |i|
        "[#{i[:id]}] <#{i[:url]}|#{i[:title]}> - #{DateTime.parse(i[:date]).strftime('%D')} - *#{i[:assignee] || '`None`'}*  "
      end.join("\n")

      @slack_client.chat_postMessage(channel: @slack_channel , text: text, as_user: true) if @slack_channel

      text
    end
  end
end
