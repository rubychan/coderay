class CSS < Hash
  
  attr_reader :mode
  
  def initialize styles = [], mode = nil
    @mode = mode
    @sorted = []
    @styles = read styles
    @styles_used = {}
    super() do |hash, key|
      hash[key] = style_for key
    end
  end
  
  def clear
    super
    @sorted.clear
  end
  
  def style_for selector, mode = @mode
    selector = selector.to_s if selector.is_a? Symbol
    case mode
    when nil: self[selector]
    when :style, :class: send mode, selector
    else
      raise
    end
    #case selector
    #when String: selector]
    #when Symbol: self[selector.to_s]
    #when Array: self[selector.last]
    #else
    #  raise ArgumentError, 'String, Symbol or Array expected, %p given' % styles.class
    #end
  end
  
  def read styles
    case styles
    when String: read_style_sheet styles
    when Array: read_style_list styles
    else
      raise ArgumentError, 'String or Array expected, %p given' % styles.class
    end
  end
  
  def read_style_list list
    for clas, style in list
      add clas, style
    end
  end
  
  def add clas, style
    @sorted << clas
    self[clas] = style
  end
  
  protected :[]=, :fetch
  
  def use selector
    @styles_used[selector] = true
  end
  
  def class selector = nil
    # redirect to Object#class if no argument given
    return super unless selector
    
    use selector
    "class=\"#{selector}\""
  end
  
  def style selector
    "style=\"#{self[selector]}\""
  end
  
  def stylesheet_tag indent = nil
    tag = <<-STYLESHEET
<style type="text/css">
#{stylesheet}
</style>
    STYLESHEET
    tag.gsub!(/^/, indent) if indent
    tag
  end
  
  def stylesheet
    @styles_used.sort_by { |sel,| sel }.map do |selector, val|
      ".#{selector} { #{self.fetch(selector)} }"
    end.join "\n"
  end
  
end

if $0 == __FILE__
  css = CSS.new [
    ['foo', 'color: blue'],
    ['bar', 'font-size: 200%'],
  ], :class
  
  puts "<span #{css[:foo]}>Test</span>"
  puts css.stylesheet_tag
end
