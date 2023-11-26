# frozen_string_literal: true

module TranSound
    module RouteHelpers
      # Application value for the path of a requested project
      class ProjectRequestPath
        def initialize(id, type, request)
          @id = id
          @type = type
          @request = request
          @path = request.remaining_path
        end
  
        attr_reader :id, :type
  
        # def folder_name
        #   @folder_name ||= @path.empty? ? '' : @path[1..]
        # end
  
        def podcast_fullname
          @request.captures.join '/'
        end
      end
    end
  end