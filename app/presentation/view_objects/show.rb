# frozen_string_literal: true

module Views
    # View for a single Show entity
    class Show
      def initialize(show, index = nil)
        @show = show
        @index = index
      end
  
      def entity
        @show
      end
  
      def praise_link
        "/show/#{fullname}"
      end
  
      def index_str
        "show[#{@index}]"
      end
  
      def contributor_names
        @show.contributors.map(&:username).join(', ')
      end
  
      def owner_name
        @show.owner.username
      end
  
      def fullname
        "#{owner_name}/#{name}"
      end
  
      def http_url
        @show.http_url
      end
  
      def name
        @show.name
      end
    end
  end