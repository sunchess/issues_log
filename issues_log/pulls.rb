module IssuesLog
  class Pulls < Base
    base_uri 'https://api.github.com/repos/Uscreen-video/uscreen_2'

    def get_pulls
      response = self.class.get("/pulls", options)
      @accumulator = JSON.parse(response.body)
      @accumulator = @accumulator.flatten.uniq

      self
    end

    def options
      {
        headers: {
          'Authorization' => "token #{@github_token}",
        }
      }
    end
  end
end
