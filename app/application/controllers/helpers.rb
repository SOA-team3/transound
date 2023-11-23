# frozen_string_literal: true

module CodePraise
    module RouteHelpers
      # Application value for the path of a requested project
      class PodcastInfoRequestPath
        def initialize(type, id, request)
          @type = type
          @id = id
          @request = request
          @path = request.remaining_path
        end
  
        attr_reader :owner_name, :project_name
  
        def folder_name
          @folder_name ||= @path.empty? ? '' : @path[1..]
        end
      end
    end
  end