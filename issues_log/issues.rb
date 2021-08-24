module IssuesLog
  class Issues < Base
    include HTTParty
    base_uri 'https://api.github.com/repos/Uscreen-video/uscreen_2'


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

      text = "*Main repo issues* \n\n"
      text << "There are *#{count}* issues ⚙️ \n\n"

      text << @accumulator.map do |i|
        "[#{i[:id]}] <#{i[:url]}|#{i[:title]}> - #{DateTime.parse(i[:date]).strftime('%D')} - *#{i[:assignee] || '`None`'}*  "
      end.join("\n")

      @slack_client.chat_postMessage(channel: @slack_channel , text: text, as_user: true) if @slack_channel

      text
    end

    private

    def pulls
    end
  end
end
