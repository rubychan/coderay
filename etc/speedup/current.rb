require 'strscan'
require 'benchmark'

class Scanner < StringScanner
  
  def initialize code
    super code
    @tokens = Tokens.new
  end
  
  def tokenize
    scan_tokens @tokens
    @tokens
  end
  
protected
  
  def scan_tokens tokens
    until eos?
      if matched = scan(/\s+/)
        tokens << [matched, :space]
      elsif matched = scan(/!/)
        tokens << [matched, :not_going_to_happen]
      elsif matched = scan(/=/)
        tokens << [matched, :not_going_to_happen]
      elsif matched = scan(/%/)
        tokens << [matched, :not_going_to_happen]
      elsif matched = scan(/\w+/)
        tokens << [matched, :word]
      elsif matched = scan(/[,.]/)
        tokens << [matched, :op]
      elsif scan(/\(/)
        tokens << [:open, :par]
      elsif scan(/\)/)
        tokens << [:close, :par]
      else
        raise
      end
    end
  end
  
end


class Tokens < Array
end


class Encoder
  
  def encode_tokens tokens
    @out = ''
    compile tokens
    @out
  end
  
protected
  
  if RUBY_VERSION >= '1.9' || defined?(JRUBY_VERSION)
    def compile tokens
      for text, kind in tokens
        token text, kind
      end
    end
  else
    def compile tokens
      tokens.each(&method(:token).to_proc)
    end
  end
  
  def token content, kind
    encoded_token =
      case content
      when ::String
        text_token content, kind
      when :open
        open kind
      when :close
        close kind
      when ::Symbol
        block_token content, kind
      else
        raise 'Unknown token content type: %p' % [content]
      end
    @out << encoded_token
  end
  
  def text_token text, kind
    if kind == :space
      text
    else
      text.gsub!(/[)\\]/, '\\\\\0')  # escape ) and \
      "#{kind}(#{text})"
    end
  end
  
  def block_token action, kind
    case action
    when :open
      open kind
    when :close
      close kind
    end
  end
  
  def open kind
    "#{kind}<"
  end
  
  def close kind
    '>'
  end
end

N = (10 ** (ARGV.first || 5).to_i)
code = "  alpha, beta, (gamma).\n" * N
scanner = Scanner.new code
encoder = Encoder.new

tokens = nil
time_scanning = Benchmark.realtime do
  tokens = scanner.tokenize
end
puts 'Scanning: %0.2fs -- %0.0f kTok/s' % [time_scanning, tokens.size / time_scanning / 1000]

time_encoding = Benchmark.realtime do
  out = encoder.encode_tokens(tokens).size
end
puts 'Encoding: %0.2fs -- %0.0f kTok/s' % [time_encoding, tokens.size / time_encoding / 1000]

time = time_scanning + time_encoding
puts 'Together: %0.2fs -- %0.0f kTok/s' % [time, tokens.size / time / 1000]
