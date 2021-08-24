module IssuesLog
  class Pulls < Base
    include HTTParty
    base_uri 'https://api.github.com/repos/Uscreen-video/uscreen_2'

    def get_pulls
      @labels.each do |label|
        response = pulls_by_label(label)
        @accumulator << JSON.parse(response.body)
      end

      @accumulator = @accumulator.flatten.uniq
      self
    end


    def pulls_by_label(label)
      options = build_options(label)
      self.class.get("/pulls", options)
    end
  end
end
