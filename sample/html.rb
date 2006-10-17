$: << '..'
require 'coderay'

tokens = CodeRay.scan DATA.read, :ruby
html = tokens.html(:tab_width => 2, :line_numbers => :table)

puts html.page

__END__
require 'scanner'

module CodeRay
	
	class RubyScanner < Scanner
		
		RESERVED_WORDS = [
			'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
			'defined?', 'ensure', 'module', 'redo', 'super', 'until',
			'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
			'when', 'END', 'case', 'else', 'for', 'retry',
			'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
			'undef', 'yield',
		]

		DEF_KEYWORDS = ['def']
		MODULE_KEYWORDS = ['class', 'module']
		DEF_NEW_STATE = WordList.new(:initial).
			add(DEF_KEYWORDS, :def_expected).
			add(MODULE_KEYWORDS, :module_expected)

		WORDS_ALLOWING_REGEXP = [
			'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
		]
		REGEXP_ALLOWED = WordList.new(false).
			add(WORDS_ALLOWING_REGEXP, :set)
		
		PREDEFINED_CONSTANTS = [
			'nil', 'true', 'false', 'self',
			'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
		]

		IDENT_KIND = WordList.new(:ident).
			add(RESERVED_WORDS, :reserved).
			add(PREDEFINED_CONSTANTS, :pre_constant)

		METHOD_NAME = / #{IDENT} [?!]? /xo
		METHOD_NAME_EX = /
		 #{METHOD_NAME}  # common methods: split, foo=, empty?, gsub!
		 | \*\*?         # multiplication and power
		 | [-+~]@?       # plus, minus
		 | [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
		 | \[\]=?        # array getter and setter
		 | <=?>? | >=?   # comparison, rocket operator
		 | << | >>       # append or shift left, shift right
		 | ===?          # simple equality and case equality
		/ox
		GLOBAL_VARIABLE = / \$ (?: #{IDENT} | \d+ | [~&+`'=\/,;_.<>!@0$?*":F\\] | -[a-zA-Z_0-9] ) /ox

		DOUBLEQ = / "  [^"\#\\]*  (?: (?: \#\{.*?\} | \#(?:$")?  | \\. ) [^"\#\\]*  )* "?  /ox
		SINGLEQ = / '  [^'\\]*    (?:                              \\.   [^'\\]*    )* '?  /ox
		STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox
		SHELL   = / `  [^`\#\\]*  (?: (?: \#\{.*?\} | \#(?:$`)?  | \\. ) [^`\#\\]*  )* `?  /ox
		REGEXP  = / \/ [^\/\#\\]* (?: (?: \#\{.*?\} | \#(?:$\/)? | \\. ) [^\/\#\\]* )* \/? /ox
		
		DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
		OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
		HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
		BINARY = /0b[01]+(?:_[01]+)*/

		EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
		FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
		INTEGER = /#{OCTAL}|#{HEXADECIMAL}|#{BINARY}|#{DECIMAL}/
		
		def reset
			super
			@regexp_allowed = false
		end
		
		def next_token
			return if @scanner.eos?

			kind = :error
			if @scanner.scan(/\s+/)  # in every state
				kind = :space
				@regexp_allowed = :set if @regexp_allowed or @scanner.matched.index(?\n)  # delayed flag setting

			elsif @state == :def_expected
				if @scanner.scan(/ (?: (?:#{IDENT}(?:\.|::))* | (?:@@?|$)? #{IDENT}(?:\.|::) ) #{METHOD_NAME_EX} /ox)
					kind = :method
					@state = :initial
				else
					@scanner.scan(/./)
					kind = :error
				end
				@state = :initial
				
			elsif @state == :module_expected
				if @scanner.scan(/<</)
					kind = :operator
				else
					if @scanner.scan(/ (?: #{IDENT} (?:\.|::))* #{IDENT} /ox)
						kind = :method
					else
						@scanner.scan(/./)
						kind = :error
					end
					@state = :initial
				end
				
			elsif # state == :initial
				# IDENTIFIERS, KEYWORDS
				if @scanner.scan(GLOBAL_VARIABLE)
					kind = :global_variable
				elsif @scanner.scan(/ @@ #{IDENT} /ox)
					kind = :class_variable
				elsif @scanner.scan(/ @ #{IDENT} /ox)
					kind = :instance_variable
				elsif @scanner.scan(/ __END__\n ( (?!\#CODE\#) .* )? | \#[^\n]* | =begin(?=\s).*? \n=end(?=\s|\z)(?:[^\n]*)? /x)
					kind = :comment
				elsif @scanner.scan(METHOD_NAME)
					if @last_token_dot
						kind = :ident
					else
						matched = @scanner.matched
						kind = IDENT_KIND[matched]
						if kind == :ident and matched =~ /^[A-Z]/
							kind = :constant
						elsif kind == :reserved
							@state = DEF_NEW_STATE[matched]
							@regexp_allowed = REGEXP_ALLOWED[matched]
						end
					end
					
				elsif @scanner.scan(STRING)
					kind = :string
				elsif @scanner.scan(SHELL)
					kind = :shell
				## HEREDOCS
				elsif @scanner.scan(/\//) and @regexp_allowed
				 	@scanner.unscan
				 	@scanner.scan(REGEXP)
					kind = :regexp
				## %strings
				elsif @scanner.scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
					kind = :global_variable
				elsif @scanner.scan(/
				  \? (?:
				    [^\s\\]
				  | 
				    \\ (?:M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-))? (?: \\ (?: . | [0-7]{3} | x[0-9A-Fa-f][0-9A-Fa-f] )
				  )
				/ox)
					kind = :integer
					
				elsif @scanner.scan(/ [-+*\/%=<>;,|&!()\[\]{}~?] | \.\.?\.? | ::? /x)
					kind = :operator
					@regexp_allowed = :set if @scanner.matched[-1,1] =~ /[~=!<>|&^,\(\[+\-\/\*%]\z/
				elsif @scanner.scan(FLOAT)
					kind = :float
				elsif @scanner.scan(INTEGER)
					kind = :integer
				elsif @scanner.scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
					kind = :global_variable
				else
					@scanner.scan(/./m)
				end
			end
			
			token = Token.new @scanner.matched, kind

			if kind == :regexp
				token.text << @scanner.scan(/[eimnosux]*/)
			end
			
			@regexp_allowed = (@regexp_allowed == :set)  # delayed flag setting

			token
		end
	end
	
	ScannerList.register RubyScanner, 'ruby'

end

module CodeRay
	require 'scanner'

	class Highlighter

		def initialize lang
			@scanner = Scanner[lang].new
		end

		def highlight code
			@scanner.feed code
			@scanner.all_tokens.map { |t| t.inspect }.join "\n"
		end

	end

	class HTMLHighlighter < Highlighter
		
		ClassOfKind = {
			:attribute_name => 'an',
			:attribute_name_fat => 'af',
			:attribute_value => 'av',
			:attribute_value_fat => 'aw',
			:bin => 'bi',
	 		:char => 'ch',
			:class => 'cl',
			:class_variable => 'cv',
			:color => 'cr',
			:comment => 'c',
			:constant => 'co',
			:definition => 'df',
			:directive => 'di',
			:doc => 'do',
			:doc_string => 'ds',
			:exception => 'ex',
			:error => 'er',
			:float => 'fl',
			:function => 'fu',
			:global_variable => 'gv',
			:hex => 'hx',
			:include => 'ic',
			:instance_variable => 'iv',
			:integer => 'i',
			:interpreted => 'in',
			:label => 'la',
			:local_variable => 'lv',
			:oct => 'oc',
			:operator_name => 'on',
			:pre_constant => 'pc',
			:pre_type => 'pt',
			:predefined => 'pd',
			:preprocessor => 'pp',
			:regexp => 'rx',
			:reserved => 'r',
			:shell => 'sh',
			:string => 's',
			:symbol => 'sy',
			:tag => 'ta',
			:tag_fat => 'tf',
			:tag_special => 'ts',
			:type => 'ty',
			:variable => 'v',
			:xml_text => 'xt',

			:ident => :NO_HIGHLIGHT,
			:operator => :NO_HIGHLIGHT,
			:space => :NO_HIGHLIGHT,
		}
		ClassOfKind[:procedure] = ClassOfKind[:method] = ClassOfKind[:function]
		ClassOfKind.default = ClassOfKind[:error] or raise 'no class found for :error!'
		
		def initialize lang, options = {}
			super lang
			
			@HTML_TAB = ' ' * options.fetch(:tabs2space, 8)
			case level = options.fetch(:level, 'xhtml')
				when 'html'
					@HTML_BR = "<BR>\n"
				when 'xhtml'
					@HTML_BR = "<br />\n"
			else
				raise "Unknown HTML level: #{level}"
			end
		end

		def highlight code
			@scanner.feed code
			
			out = ''
			while t = @scanner.next_token
				warn t.inspect if t.text.nil?
				out << to_html(t)
			end
			TEMPLATE =~ /<%CONTENT%>/
			$` + out + $'
		end
		
	private
		def to_html token
			css_class = ClassOfKind[token.kind]
			if defined? ::DEBUG and not ClassOfKind.has_key? token.kind
				warn "no token class found for :#{token.kind}"
			end
				
			text = text_to_html token.text
			if css_class == :NO_HIGHLIGHT
				text
			else
				"<span class=\"#{css_class}\">#{text}</span>"
			end
		end
		
		def text_to_html text
			return '' if text.empty?
			text = text.dup  # important
			if text.index(/["><&]/)
				text.gsub!('&', '&amp;')
				text.gsub!('"', '&quot;')
				text.gsub!('>', '&gt;')
				text.gsub!('<', '&lt;')
			end
			if text.index(/\s/)
				text.gsub!("\n", @HTML_BR)
				text.gsub!("\t", @HTML_TAB)
				text.gsub!(/^ /, '&nbsp;')
				text.gsub!('  ', ' &nbsp;')
			end
			text
		end
		
		TEMPLATE = <<-'TEMPLATE'
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html dir="ltr">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Content-Style-Type" content="text/css">

<title>RubyBB BBCode</title>
<style type="text/css">
.code {
	width: 100%;
	background-color: #FAFAFA;
	border: 1px solid #D1D7DC;
	font-family: 'Courier New', 'Terminal', monospace;
	font-size: 10pt;
	color: black;
	vertical-align: top;
	text-align: left;
}
.code .af { color:#00C; }
.code .an { color:#007; }
.code .av { color:#700; }
.code .aw { color:#C00; }
.code .bi { color:#509; font-weight:bold; }
.code .c  { color:#888; }
.code .ch { color:#C28; font-weight:bold; }
.code .cl { color:#B06; font-weight:bold; }
.code .co { color:#036; font-weight:bold; }
.code .cr { color:#0A0; }
.code .cv { color:#369; }
.code .df { color:#099; font-weight:bold; }
.code .di { color:#088; font-weight:bold; }
.code .do { color:#970; }
.code .ds { color:#D42; font-weight:bold; }
.code .er { color:#F00; background-color:#FAA; }
.code .ex { color:#F00; font-weight:bold; }
.code .fl { color:#60E; font-weight:bold; }
.code .fu { color:#06B; font-weight:bold; }
.code .gv { color:#800; font-weight:bold; }
.code .hx { color:#058; font-weight:bold; }
.code .i  { color:#00D; font-weight:bold; }
.code .ic { color:#B44; font-weight:bold; }
.code .in { color:#B2B; font-weight:bold; }
.code .iv { color:#33B; }
.code .la { color:#970; font-weight:bold; }
.code .lv { color:#963; }
.code .oc { color:#40E; font-weight:bold; }
.code .on { color:#000; font-weight:bold; }
.code .pc { color:#038; font-weight:bold; }
.code .pd { color:#369; font-weight:bold; }
.code .pp { color:#579; }
.code .pt { color:#339; font-weight:bold; }
.code .r  { color:#080; font-weight:bold; }
.code .rx { color:#927; font-weight:bold; }
.code .s  { color:#D42; font-weight:bold; }
.code .sh { color:#B2B; font-weight:bold; }
.code .sy { color:#A60; }
.code .ta { color:#070; }
.code .tf { color:#070; font-weight:bold; }
.code .ts { color:#D70; font-weight:bold; }
.code .ty { color:#339; font-weight:bold; }
.code .v  { color:#036; }
.code .xt { color:#444; }
</style>
</head>
<body>
<div class="code">
<%CONTENT%>
</div>
<div class="validators">
<a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-html401" alt="Valid HTML 4.01!" height="31" width="88" style="border:none;"></a>
<img style="border:0" src="http://jigsaw.w3.org/css-validator/images/vcss" alt="Valid CSS!" >
</div>    
</body>
</html>
		TEMPLATE

	end

end
