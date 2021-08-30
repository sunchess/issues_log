module IssuesLog
  class Issues < Base
    base_uri 'https://api.github.com/repos/Uscreen-video/uscreen_2'

    def get_issues
      @labels.each do |label|
        response = issues_by_label(label)
        @accumulator << JSON.parse(response.body)
      end

      @accumulator = @accumulator.flatten.uniq.select { |i| i['pull_request'].nil? }
      self
    end

    def format!
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
      return if count == 0

      text = "*Main repo issues* \n\n"

      if ENV['ISSUES_SHORT_FORMAT']
        link = "https://github.com/Uscreen-video/uscreen_2/issues?q=#{CGI::escape("is:issue is:open label:\"#{@labels.first}\"")}"
        text << "There are <#{link}|*#{count}* issues> 💡 \n\n"
      else
        text << "There are *#{count}* issues 💡 \n\n"
        text << @accumulator.map do |i|
          "[#{i[:id]}] <#{i[:url]}|#{i[:title]}> - #{DateTime.parse(i[:date]).strftime('%D')} - *#{i[:assignee] || '`None`'}*  "
        end.join("\n")
      end

      @slack_client.chat_postMessage(channel: @slack_channel , text: text, as_user: true) if @slack_channel

      text
    end

    private
  end
end
