module CodeRay
module Encoders
  class HTML
    module Output
      def self.wrap_string_in string, element, css = nil
        case element
        when :span
          SPAN
        when :div
          return string if string[/\A<(?:div|table)\b/]
          DIV
        when :page
          string = wrap_string_in(string, :div) unless string[/\A<(?:div|table)\b/]
          PAGE.sub('<%CSS%>', css ? css.stylesheet : '')
        else
          raise ArgumentError, 'Unknown wrap element: %p' % [element]
        end.sub('<%CONTENT%>', string)
      end
      
      SPAN = '<span class="CodeRay"><%CONTENT%></span>'
      
      DIV = <<-DIV
<div class="CodeRay">
  <div class="code"><pre><%CONTENT%></pre></div>
</div>
      DIV
      
      PAGE = <<-PAGE
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title></title>
  <style type="text/css">
.CodeRay .line-numbers a {
  text-decoration: inherit;
  color: inherit;
}
body {
  background-color: white;
  padding: 0;
  margin: 0;
}
<%CSS%>
.CodeRay {
  border: none;
}
  </style>
</head>
<body>

<%CONTENT%>
</body>
</html>
      PAGE
    end
  end
end
end
