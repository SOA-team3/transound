# frozen_string_literal: true

<<<<<<< HEAD
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
=======
module TranSound
  module RouteHelpers
    # Application value for the path of a requested project
    class PodcastInfoRequestPath
      def initialize(type, id, _request)
        @type = type
        @id = id
      end

      attr_reader :type, :id
    end
  end
end
>>>>>>> 3435dcb13ec8337b581bfdf1fafc14ecce5d1824
