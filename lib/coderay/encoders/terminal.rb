module CodeRay
  module Encoders
    
    # Outputs code highlighted for a color terminal.
    # 
    # Note: This encoder is in beta. It currently doesn't use the Styles.
    # 
    # Alias: +term+
    # 
    # == Authors & License
    # 
    # By Rob Aldred (http://robaldred.co.uk)
    # 
    # Based on idea by Nathan Weizenbaum (http://nex-3.com)
    # 
    # MIT License (http://www.opensource.org/licenses/mit-license.php)
    class Terminal < Encoder
      
      register_for :terminal
      
      TOKEN_COLORS = {
        :annotation => "\e[35m",
        :attribute_name => "\e[33m",
        :attribute_value => "\e[31m",
        :binary => "\e[1;35m",
        :char => {
          :self => "\e[36m", :delimiter => "\e[1;34m"
        },
        :class => "\e[1;35m",
        :class_variable => "\e[36m",
        :color => "\e[32m",
        :comment => "\e[37m",
        :complex => "\e[1;34m",
        :constant => "\e[1;34m\e[4m",
        :decoration => "\e[35m",
        :definition => "\e[1;32m",
        :directive => "\e[32m\e[4m",
        :doc => "\e[46m",
        :doctype => "\e[1;30m",
        :doc_string => "\e[31m\e[4m",
        :entity => "\e[33m",
        :error => "\e[1;33m\e[41m",
        :exception => "\e[1;31m",
        :float => "\e[1;35m",
        :function => "\e[1;34m",
        :global_variable => "\e[42m",
        :hex => "\e[1;36m",
        :include => "\e[33m",
        :integer => "\e[1;34m",
        :key => "\e[35m",
        :label => "\e[1;15m",
        :local_variable => "\e[33m",
        :octal => "\e[1;35m",
        :operator_name => "\e[1;29m",
        :predefined_constant => "\e[1;36m",
        :predefined_type => "\e[1;30m",
        :predefined => "\e[4m\e[1;34m",
        :preprocessor => "\e[36m",
        :pseudo_class => "\e[1;34m",
        :regexp => {
          :self => "\e[31m",
          :content => "\e[31m",
          :delimiter => "\e[1;29m",
          :modifier => "\e[35m",
        },
        :reserved => "\e[1;31m",
        :shell => {
          :self => "\e[42m",
          :content => "\e[1;29m",
          :delimiter => "\e[37m",
        },
        :string => {
          :self => "\e[32m",
          :modifier => "\e[1;32m",
          :escape => "\e[1;36m",
          :delimiter => "\e[1;32m",
          :char => "\e[1;36m",
        },
        :symbol => "\e[1;32m",
        :tag => "\e[1;34m",
        :type => "\e[1;34m",
        :value => "\e[36m",
        :variable => "\e[1;34m",
        
        :insert => "\e[42m",
        :delete => "\e[41m",
        :change => "\e[44m",
        :head => "\e[45m"
      }
      TOKEN_COLORS[:keyword] = TOKEN_COLORS[:reserved]
      TOKEN_COLORS[:method] = TOKEN_COLORS[:function]
      TOKEN_COLORS[:imaginary] = TOKEN_COLORS[:complex]
      TOKEN_COLORS[:begin_group] = TOKEN_COLORS[:end_group] =
        TOKEN_COLORS[:escape] = TOKEN_COLORS[:delimiter]
      
    protected
      
      def setup(options)
        super
        @opened = []
        @subcolors = nil
      end
      
    public
      
      def text_token text, kind
        if color = (@subcolors || TOKEN_COLORS)[kind]
          if Hash === color
            if color[:self]
              color = color[:self]
            else
              @out << text
              return
            end
          end
          
          @out << color
          @out << text.gsub("\n", "\e[0m\n" + color)
          @out << "\e[0m"
          @out << @subcolors[:self] if @subcolors
        else
          @out << text
        end
      end
      
      def begin_group kind
        @opened << kind
        @out << open_token(kind)
      end
      alias begin_line begin_group
      
      def end_group kind
        if @opened.empty?
          # nothing to close
        else
          @opened.pop
          @out << "\e[0m"
          @out << open_token(@opened.last)
        end
      end
      
      def end_line kind
        if @opened.empty?
          # nothing to close
        else
          @opened.pop
          # whole lines to be highlighted,
          # eg. added/modified/deleted lines in a diff
          @out << (@line_filler ||= "\t" * 100 + "\e[0m")
          @out << open_token(@opened.last)
        end
      end
      
    private
      
      def open_token kind
        if color = TOKEN_COLORS[kind]
          if Hash === color
            @subcolors = color
            color[:self]
          else
            @subcolors = {}
            color
          end
        else
          @subcolors = nil
          ''
        end
      end
    end
  end
end
