# -*- encoding: utf-8 -*-

module CodeRay
  module Encoders

    # = LaTeX Encoder
    #
    # Encode CodeRay tokens to LaTeX so you can use CodeRay’s
    # superior highlighting in LaTeX’s superior typesetting.
    # The LaTeX code generated depends on one single LaTeX package,
    # `xcolor`, which has to be loaded as usual.
    #
    # The generated LaTeX code is a large blob of specific commands
    # that typeset a monospaced section of text. It does _not_ use
    # LaTeX’s `verbatim` environment, hence placing the result
    # at certain places where this is problematic should be possible.
    # The code makes use of a number of custom commands that
    # are not defined by default. You can retrieve these by
    # calling ::preamble_snippet, which also defines all the
    # colors and styling used in the highlighting code.
    #
    # Each highlight block automatically switches to vertical mode
    # and executes <tt>\par</tt> at its end, so whatever follows
    # starts a new paragraph. Highlighting blocks also execute
    # <tt>\noindent</tt> at the beginning, so they will never be
    # subject to LaTeX’s paragraph indentation.
    #
    # Highlighting blocks are not floating. They will be inserted
    # right where you include them. You can build your own floating
    # environment around them if you want.
    #
    # Before you can use a CodeRay-highlighted block in your LaTeX
    # document, you have to include some code in your preamble. You
    # can retrieve this code by calling ::preamble_snippet. It defines
    # some helper commands and, most importantly, the colors used so
    # that you can easily adapt it to your likening.
    #
    # == Unicode notice
    #
    # Today’s sourcecode files often contain Unicode characters.
    # When confronted with such a file, typesetting the result of
    # the CodeRay highlighting process with pdflatex will fail
    # like this:
    #
    #   ! Package inputenc Error: Unicode char \u8:─ not set up for use with LaTeX.
    #
    # Use a Unicode-aware TeX implementation such as LuaTex (LuaLaTeX)
    # instead, and all will work fine. You should be doing that
    # anyway.
    #
    # == Usage
    #
    # Ruby code:
    #
    #   require "coderay"
    #   puts CodeRay.scan('Some /code/', :ruby).latex #=> LaTeX snippet
    #   puts CodeRay.scan('Some code', :ruby).latex(
    #     :line_numbers => true,
    #     :mix_delimiters => true)
    #  )
    #
    # LaTeX code (for LuaLaTeX):
    #
    #   \documentclass[11pt,a4paper]{scrartcl} % Whatever you like
    #   \usepackage[ngerman]{babel} % Whatever you like
    #   \usepackage{fontspec} % Not required, but recommended
    #   \usepackage{xcolor} % Required
    #
    #   \include{coderay-preamble} % Result of the ::preamble_snippet method!
    #   \begin{document}
    #   \input{hilit} % This should contain a coderay-highlited LaTeX snippet.
    #   \end{document}
    #
    # == Options
    #
    # === :tab_width
    # Number of spaces to insert for a tabulation character.
    # Behaves slightly different if <tt>:show_whitespace</tt>
    # is given also, see there for explanation.
    #
    # === :line_numbers
    # Print the line number in front of each line. You can customize
    # the look by redefining the `\coderaylinumstyle` command.
    #
    # === :line_numbers_start
    # Number of the first line.
    #
    # Default: 1
    #
    # Default: false
    #
    # === :bold_every
    # Format every nth line bold, where n is the value of this
    # option. Actually, you can influence the format the
    # way you like, just redefine `\coderayboldlinumstyle`,
    # which is applied after `\coderaylinumstyle`.
    #
    # Default: 10
    #
    # === mix_delimiters
    # Use `xcolor`’s color mixing facilities to make inline
    # delimiters (e.g. for strings and inline code) look
    # more appealing by mixing their color together from
    # the nesting element colors.
    #
    # === show_whitespace
    # Use a replacement character (U+2432 OPEN BOX, ␣) to emphasize the
    # presence of spaces.
    #
    # Tabs are also replaced with emphasizing characters, in this
    # case U+2500 and U+25BB (─▻) where the length of the arrow shaft
    # is determined by the <tt>:tab_width</tt> option.
    #
    # Requires a Unicode-aware LaTeX engine such as LuaLaTeX (pdflatex
    # won’t work probably), and a font supporting the used glyphs. At
    # time of writing (April 2015), Computer Modern Typewriter,
    # LaTeX’s default monospace font, supports the U+2432 character,
    # but not the U+2500 and U+25BB characters.
    #
    # Default: false
    #
    # Default: false
    class LaTeXEncoder < Encoder

      register_for :latex

      # CodeRay file extension define.
      FILE_EXTENSION = "tex"

      # Default values for the options.
      DEFAULT_OPTIONS = {
        :tab_width => 8,
        :line_numbers => false,
        :line_numbers_start => 1,
        :bold_every => 10,
        :mix_delimiters => false,
        :show_whitespace => false
      }

      # LaTeX is picky on some characters. This hash
      # maps those characters to an unambigous replacement.
      LATEX_ESCAPES = {
        "\\" => "\\textbackslash{}",
        /(?<!\\textbackslash)\{/ => "\\{",   # We do not want to re-substitute the backslashes we
        /(?<!\\textbackslash\{)\}/ => "\\}", # inserted above with the \ replacement.
        "$" => "\\$",
        "_" => "\\textunderscore{}",
        "~" => "\\coderay@tildeescape{}",
        "%" => "\\textpercent{}",
        "#" => "\\#",
        "&" => "\\textampersand{}",
        '"' => "\\coderay@quoteescape{}",
        "^" => "\\coderay@circumflexescape{}"
      }

      # Generates a LaTeX preamble snippet you can customize for
      # your desired highlighting colors.
      def self.preamble_snippet
        <<'EOF'
%% CodeRay LaTeX highlighter configuration.
%%
% Use the \include command in your LaTeX preamble to include
% this file into your project.

\makeatletter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Color definitions.

\definecolor{crdebug}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@debug[1]{\textcolor{crdebug}{\mdseries{}\upshape{}#1}}

\definecolor{crannotation}{rgb/cmyk}{0,0,44/0,0,0,1}
\newcommand\coderaystyle@annotation[1]{\textcolor{crannotation}{\mdseries{}\upshape{}#1}}

\definecolor{crattributename}{rgb/cmyk}{0.7,0.25,0.5/0,0,0,1}
\newcommand\coderaystyle@attributename[1]{\textcolor{crattributename}{\mdseries{}\upshape{}#1}}

\definecolor{crattributevalue}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@attributevalue[1]{\textcolor{crattributevalue}{\mdseries{}\upshape{}#1}}

\definecolor{crbinary}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@binary[1]{\textcolor{crbinary}{\mdseries{}\upshape{}#1}}

\definecolor{crchar}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@char[1]{\textcolor{crchar}{\mdseries{}\upshape{}#1}}

\definecolor{crclass}{rgb/cmyk}{0.7,0,0.38/0,0,0,1}
\newcommand\coderaystyle@class[1]{\textcolor{crclass}{\mdseries{}\upshape{}#1}}

\definecolor{crclassvariable}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@classvariable[1]{\textcolor{crclassvariable}{\mdseries{}\upshape{}#1}}

\definecolor{crcolor}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@color[1]{\textcolor{crcolor}{\mdseries{}\upshape{}#1}}

\definecolor{crcomment}{rgb/cmyk}{0.47,0.47,0.47/0,0,0,1}
\newcommand\coderaystyle@comment[1]{\textcolor{crcomment}{\mdseries{}\upshape{}#1}}

\definecolor{crconstant}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@constant[1]{\textcolor{crconstant}{\mdseries{}\upshape{}#1}}

\definecolor{crcontent}{rgb/cmyk}{0,0.19,0.38/0,0,0,1}
\newcommand\coderaystyle@content[1]{\textcolor{crcontent}{\bfseries{}\upshape{}#1}}

\definecolor{crdecorator}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@decorator[1]{\textcolor{crdecorator}{\mdseries{}\upshape{}#1}}

\definecolor{crdefinition}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@definition[1]{\textcolor{crdefinition}{\mdseries{}\upshape{}#1}}

\definecolor{crdelimiter}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@delimiter[1]{\textcolor{crdelimiter}{\mdseries{}\upshape{}#1}}

\definecolor{crdirective}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@directive[1]{\textcolor{crdirective}{\mdseries{}\upshape{}#1}}

\definecolor{crdoctype}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@doctype[1]{\textcolor{crdoctype}{\mdseries{}\upshape{}#1}}

\definecolor{crdocstring}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@docstring[1]{\textcolor{crdocstring}{\mdseries{}\upshape{}#1}}

\definecolor{crdone}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@done[1]{\textcolor{crdone}{\mdseries{}\upshape{}#1}}

\definecolor{crentity}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@entity[1]{\textcolor{crentity}{\mdseries{}\upshape{}#1}}

\definecolor{crerror}{rgb/cmyk}{1,0,0/0,0,0,1}
\newcommand\coderaystyle@error[1]{\textcolor{crerror}{\mdseries{}\upshape{}#1}}

\definecolor{crescape}{rgb/cmyk}{0.4,0.4,0.4/0,0,0,1}
\newcommand\coderaystyle@escape[1]{\textcolor{crescape}{\mdseries{}\upshape{}#1}}

\definecolor{crexception}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@exception[1]{\textcolor{crexception}{\mdseries{}\upshape{}#1}}

\definecolor{crfilename}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@filename[1]{\textcolor{crfilename}{\mdseries{}\upshape{}#1}}

\definecolor{crfloat}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@float[1]{\textcolor{crfloat}{\mdseries{}\upshape{}#1}}

\definecolor{crfunction}{rgb/cmyk}{0.38,0,0.88/0,0,0,1}
\newcommand\coderaystyle@function[1]{\textcolor{crfunction}{\mdseries{}\upshape{}#1}}

\definecolor{crglobalvariable}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@globalvariable[1]{\textcolor{crglobalvariable}{\mdseries{}\upshape{}#1}}

\definecolor{crhex}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@hex[1]{\textcolor{crhex}{\mdseries{}\upshape{}#1}}

\definecolor{crid}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@id[1]{\textcolor{crid}{\mdseries{}\upshape{}#1}}

\definecolor{crimaginary}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@imaginary[1]{\textcolor{crimaginary}{\mdseries{}\upshape{}#1}}

\definecolor{crimportant}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@important[1]{\textcolor{crimportant}{\mdseries{}\upshape{}#1}}

\definecolor{crinclude}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@include[1]{\textcolor{crinclude}{\mdseries{}\upshape{}#1}}

\definecolor{crinline}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@inline[1]{\textcolor{crinline}{\mdseries{}\upshape{}#1}}

\definecolor{crinlinedelimiter}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@inlinedelimiter[1]{\textcolor{crinlinedelimiter}{\mdseries{}\upshape{}#1}}

\definecolor{crinstancevariable}{rgb/cmyk}{0.19,0.19,0.69/0,0,0,1}
\newcommand\coderaystyle@instancevariable[1]{\textcolor{crinstancevariable}{\mdseries{}\upshape{}#1}}

\definecolor{crinteger}{rgb/cmyk}{0,0,0.82/0,0,0,1}
\newcommand\coderaystyle@integer[1]{\textcolor{crinteger}{\mdseries{}\upshape{}#1}}

\definecolor{crkey}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@key[1]{\textcolor{crkey}{\mdseries{}\upshape{}#1}}

\definecolor{crkeyword}{rgb/cmyk}{0,0.5,0/0,0,0,1}
\newcommand\coderaystyle@keyword[1]{\textcolor{crkeyword}{\bfseries{}\upshape{}#1}}

\definecolor{crlabel}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@label[1]{\textcolor{crlabel}{\mdseries{}\upshape{}#1}}

\definecolor{crlocalvariable}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@localvariable[1]{\textcolor{crlocalvariable}{\mdseries{}\upshape{}#1}}

\definecolor{crmap}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@map[1]{\textcolor{crmap}{\mdseries{}\upshape{}#1}}

\definecolor{crmodifier}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@modifier[1]{\textcolor{crmodifier}{\mdseries{}\upshape{}#1}}

\definecolor{crnamespace}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@namespace[1]{\textcolor{crnamespace}{\mdseries{}\upshape{}#1}}

\definecolor{croctal}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@octal[1]{\textcolor{croctal}{\mdseries{}\upshape{}#1}}

\definecolor{crpredefined}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@predefined[1]{\textcolor{crpredefined}{\mdseries{}\upshape{}#1}}

\definecolor{crpredefinedconstant}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@predefinedconstant[1]{\textcolor{crpredefinedconstant}{\mdseries{}\upshape{}#1}}

\definecolor{crpredefinedtype}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@predefinedtype[1]{\textcolor{crpredefinedtype}{\mdseries{}\upshape{}#1}}

\definecolor{crpreprocessor}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@preprocessor[1]{\textcolor{crpreprocessor}{\mdseries{}\upshape{}#1}}

\definecolor{crpseudoclass}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@pseudoclass[1]{\textcolor{crpseudoclass}{\mdseries{}\upshape{}#1}}

\definecolor{crregexp}{rgb/cmyk}{0,0,1/0,0,0,1}
\newcommand\coderaystyle@regexp[1]{\textcolor{crregexp}{\mdseries{}\upshape{}#1}}

\definecolor{crreserved}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@reserved[1]{\textcolor{crreserved}{\mdseries{}\upshape{}#1}}

\definecolor{crshell}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@shell[1]{\textcolor{crshell}{\mdseries{}\upshape{}#1}}

\definecolor{crstring}{rgb/cmyk}{0.81,0.13,0/0,0,0,1}
\newcommand\coderaystyle@string[1]{\textcolor{crstring}{\mdseries{}\upshape{}#1}}

\definecolor{crsymbol}{rgb/cmyk}{0.63,0.38,0/0,0,0,1}
\newcommand\coderaystyle@symbol[1]{\textcolor{crsymbol}{\mdseries{}\upshape{}#1}}

\definecolor{crtag}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@tag[1]{\textcolor{crtag}{\mdseries{}\upshape{}#1}}

\definecolor{crtype}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@type[1]{\textcolor{crtype}{\mdseries{}\upshape{}#1}}

\definecolor{crvalue}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@value[1]{\textcolor{crvalue}{\mdseries{}\upshape{}#1}}

\definecolor{crvariable}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@variable[1]{\textcolor{crvariable}{\mdseries{}\upshape{}#1}}

\definecolor{crchange}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@change[1]{\textcolor{crchange}{\mdseries{}\upshape{}#1}}

\definecolor{crdelete}{rgb/cmyk}{1,0,0/0,0,0,1}
\newcommand\coderaystyle@delete[1]{\textcolor{crdelete}{\mdseries{}\upshape{}#1}}

\definecolor{crhead}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@head[1]{\textcolor{crhead}{\mdseries{}\upshape{}#1}}

\definecolor{crinsert}{rgb/cmyk}{0,1,0/0,0,0,1}
\newcommand\coderaystyle@insert[1]{\textcolor{crinsert}{\mdseries{}\upshape{}#1}}

\definecolor{creyecatcher}{rgb/cmyk}{0,0,0/0,0,0,1}
\newcommand\coderaystyle@eyecatcher[1]{\textcolor{creyecatcher}{\mdseries{}\upshape{}#1}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Further style macros.

% Main style executed at the beginning of a highlighting block.
\newcommand\coderaymainstyle{\ttfamily\footnotesize}

% Style executed before formatting a line number, if enabled.
\newcommand\coderaylinumstyle{\normalcolor{}\mdseries{}\upshape{}}

% Style executed before formatting a bold line number, if enabled.
% Note that in case of bold line numbers, \coderaylinumstyle is
% executed prior to this.
\newcommand\coderayboldlinumstyle{\bfseries{}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper commands used by CodeRay's LaTeX highlighter.
% Do not change.

\newcommand\coderay@quoteescape{"} % LaTeX chokes if multiple " in a row are encountered, so we have to escape it with a macro.
\newcommand\coderay@tildeescape{\~} % Same here
\newcommand\coderay@circumflexescape{\^} % Same here

% pdflatex does not have this, but LuaLaTeX has.
\providecommand\textpercent{\%}

\makeatother
EOF
      end

      protected

      # Outputs the correct \coderaystyle@<token> command, without the
      # mandatory argument. This has to be appended manually.
      def css2format(cssname)
        tokenname = cssname.gsub("-", "") # No "-" in LaTeX color names.
        "\\coderaystyle@#{tokenname}"
      end

      # The replacement character for the space.
      # Ensure this can be concatenated to produce
      # the desired effect.
      def space
        if @show_whitespace
          "␣"
        else
          "\\phantom{~}"
        end
      end

      # The replacement string for the tab.
      def tab
        if @show_whitespace
          "─" * (@tabwidth - 1) + "▻"
        else
          space * @tabwidth
        end
      end

      # CodeRay setup callback.
      def setup(options)
        super

        @colormix = []
        @out = ""
        @mix_delimiters = options[:mix_delimiters]
        @show_whitespace = options[:show_whitespace]
        @tabwidth = options[:tab_width]
      end

      # CodeRay finish callback.
      def finish(options)
        if options[:line_numbers]
          numlen = @out.lines.count.to_s.chars.count
          @out = @out.each_line.with_index.map{|line, idx|
            lino = idx + options[:line_numbers_start]
            extra = lino % options[:bold_every] == 0 ? "\\coderayboldlinumstyle{}" : ""

            sprintf("{\\coderaylinumstyle{}#{extra}%#{numlen}d}~#{line}", lino).gsub(" ", space)
          }.join("")
        end

        # I prepend this here and not in #setup, because this should not be
        # counted during line numbering.
        @out.prepend("\\par\\begingroup\\makeatletter\\coderaymainstyle\\noindent\n")
        @out << "\n\\makeatother\\endgroup\\par"

        super
      end

      # Escape all teXnically problematic characters in +str+.
      def escape_latex(str)
        str = str.dup

        LATEX_ESCAPES.each_pair do |pattern, replacement|
          str.gsub!(pattern, replacement)
        end

        str
      end

      # Examine the color stack and return a mixed color.
      def mix_current_colors
        # For each depth level, mix in more black.
        blackpart = 10 * @colormix.length
        blackpart = 90 if blackpart > 90 # Maximum darkening

        # From the rest that remains, mix in all level’s group colors
        # in equal parts.
        part = 100 / @colormix.length.to_f
        colorpart = @colormix.map{|kind| "cr" + TokenKinds[kind].gsub("-", "")}.inject("") do |str, colorname|
          str + "!" + colorname + "!" + part.to_s
        end

        "black!#{blackpart}#{colorpart}"
      end

      public

      # CodeRay inline token callback.
      def text_token(text, kind)
        text = escape_latex(text)
        text.gsub!(" ", space) # Disallow line breaks, we don’t want that in code.
        text.gsub!("\t", tab)
        text.gsub!("\n"){"\\\\\n"} # Without block you hit a well-known pitfall -- that’d be just too many \. \\ required for LaTeX hard line break.

        if cssclass = TokenKinds[kind] # Single = intended
          if @mix_delimiters && (kind == :delimiter || kind == :inline_delimiter)
            @out << "\\textcolor{#{mix_current_colors}}{" << text << "}"
          else
            @out << css2format(cssclass) << "{" << text << "}"
          end
        else
          @out << text
        end
      end

      # CodeRay begin group callback.
      def begin_group(kind)
        # css class existance check like in #text_token is not needed,
        # because there are no groups not intended to be highlighted.
        @out << css2format(TokenKinds[kind]) << "{"
        @colormix.push(kind)
      end

      # CodeRay end group callback.
      def end_group(kind)
        @out << "}"
        @colormix.pop
      end

      # CodeRay line start callback (e.g. diffs).
      def begin_line(kind)
        @out << "\\colorbox{cr#{TokenKinds[kind].gsub('-', '')}}{"
      end

      # CodeRay line end callback (e.g. diffs)
      def end_line(kind)
        @out << "}"
      end

    end
  end
end
