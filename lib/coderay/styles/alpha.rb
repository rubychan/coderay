module CodeRay
  module Styles

    # A colorful theme using CSS 3 colors (with alpha channel).
    class Alpha < Style

      register_for :alpha

      CSS_MAIN_STYLES = open("#{$:.select {|x| x =~ /coderay/}.first}/coderay/styles/css/alpha.css").read
      TOKEN_COLORS = open("#{$:.select {|x| x =~ /coderay/}.first}/coderay/styles/css/alpha_tokens.css").read
    end

  end
end
