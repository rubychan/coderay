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
        :attribute_name => '33',
        :attribute_value => '31',
        :bin => '1;35',
        :char => {
          :self => '36', :delimiter => '34'
        },
        :class => '1;35',
        :class_variable => '36',
        :color => '32',
        :comment => '37',
        :constant => ['34', '4'],
        :definition => '1;32',
        :directive => ['32', '4'],
        :doc => '46',
        :doc_string => ['31', '4'],
        :entity => '33',
        :error => ['1;33', '41'],
        :exception => '1;31',
        :float => '1;35',
        :function => '1;34',
        :global_variable => '42',
        :hex => '1;36',
        :include => '33',
        :integer => '1;34',
        :interpreted => '1;35',
        :label => '1;15',
        :local_variable => '33',
        :oct => '1;35',
        :operator_name => '1;29',
        :pre_constant => '1;36',
        :pre_type => '1;30',
        :predefined => ['4', '1;34'],
        :preprocessor => '36',
        :regexp => {
          :self => '31',
          :content => '31',
          :delimiter => '1;29',
          :modifier => '35',
          :function => '1;29'
        },
        :reserved => '1;31',
        :shell => {:self => '42', :content => '1;29'},
        :string => '32',
        :symbol => '1;32',
        :tag => '34',
        :tag_special => ['34', '4'],
        :type => '1;34',
        :variable => '34',
        
        :insert => '42',
        :delete => '41',
        :change => '44',
        :head => '41'
      }
      TOKEN_COLORS[:method] = TOKEN_COLORS[:function]
      TOKEN_COLORS[:open] = TOKEN_COLORS[:close] = TOKEN_COLORS[:nesting_delimiter] = TOKEN_COLORS[:escape] = TOKEN_COLORS[:delimiter]

    protected

      def setup(options)
        super
        @opened = []
      end

      def finish(options)
        super
      end
    
      def text_token text, type
        if color = (@subcolors || TOKEN_COLORS)[type]
          if Hash === color
            if color[:self]
              color = color[:self]
            else
              return text
            end
          end

          out = ansi_colorize(color)
          out << text.gsub("\n", ansi_clear + "\n" + ansi_colorize(color))
          out << ansi_clear
          out << ansi_colorize(@subcolors[:self]) if @subcolors && @subcolors[:self]
          out
        else
          text
        end
      end
      
      def open_token type
        if color = TOKEN_COLORS[type]
          if Hash === color
            @subcolors = color
            ansi_colorize(color[:self]) if color[:self]
          else
            @subcolors = {}
            ansi_colorize(color)
          end
        else
          @subcolors = nil
          ''
        end
      end
      
      def block_token action, type
        case action
          
        when :open, :begin_line
          @opened << type
          open_token type
        when :close, :end_line
          if @opened.empty?
            # nothing to close
          else
            @opened.pop
            if action == :end_line
              # whole lines to be highlighted,
              # eg. added/modified/deleted lines in a diff
              "\t" * 100 + ansi_clear
            else
              ansi_clear
            end +
              open_token(@opened.last)
          end
          
        else
          raise 'unknown token kind: %p' % [text]
        end
      end
      
    private
      
      def ansi_colorize(color)
        Array(color).map { |c| "\e[#{c}m" }.join
      end
      def ansi_clear
        ansi_colorize(0)
      end
    end
  end
end