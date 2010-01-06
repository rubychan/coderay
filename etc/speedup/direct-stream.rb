require 'strscan'
require 'benchmark'

class Scanner < StringScanner
  
  def initialize code
    super code
  end
  
  def tokenize encoder = Tokens.new
    scan_tokens encoder
    encoder
  end
  
protected
  
  def scan_tokens encoder
    until eos?
      if matched = scan(/\s+/)
        encoder.text_token matched, :space
      elsif matched = scan(/!/)
        encoder.text_token matched, :not_going_to_happen
      elsif matched = scan(/=/)
        encoder.text_token matched, :not_going_to_happen
      elsif matched = scan(/%/)
        encoder.text_token matched, :not_going_to_happen
      elsif matched = scan(/\w+/)
        encoder.text_token matched, :word
      elsif matched = scan(/[,.]/)
        encoder.text_token matched, :op
      elsif scan(/\(/)
        encoder.open :par
      elsif scan(/\)/)
        encoder.close :par
      else
        raise
      end
    end
  end
  
end


class Tokens < Array
  alias token push
  alias text_token push
  alias block_token push
  def open kind; push :open, kind end
  def close kind; push :close, kind end
end


class Encoder
  
  def setup
    @out = ''
    @opened = []
  end
  
  def finish
    while kind = @opened.pop
      close kind
    end
    @out
  end
  
  def encode_tokens tokens
    setup
    compile tokens
    finish
  end
  
  def encode_stream scanner
    setup
    scanner.tokenize self
    finish
  end
  
  def token content, kind
    if content.is_a? ::String
      text_token content, kind
    elsif content.is_a? ::Symbol
      block_token content, kind
    else
      raise 'Unknown token content type: %p' % [content]
    end
  end
  
  def text_token text, kind
    @out <<
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
    else
      raise
    end
  end
  
  def open kind
    @opened << kind
    @out << "#{kind}<"
  end
  
  def close kind
    @opened.pop
    @out << '>'
  end
  
protected
  
  def compile tokens
    content = nil
    for item in tokens
      if content
        case content
        when ::String
          text_token content, item
          content = nil
        when :open
          open item
          content = nil
        when :close
          close item
          content = nil
        when ::Symbol
          block_token content, kind
          content = nil
        else
          raise
        end
      else
        content = item
      end
    end
    raise if content
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
puts 'Scanning: %0.2fs -- %0.0f kTok/s' % [time_scanning, tokens.size / 2 / time_scanning / 1000]

time_encoding = Benchmark.realtime do
  encoder.encode_tokens tokens
end
puts 'Encoding: %0.2fs -- %0.0f kTok/s' % [time_encoding, tokens.size / 2 / time_encoding / 1000]

time = time_scanning + time_encoding
puts 'Together: %0.2fs -- %0.0f kTok/s' % [time, tokens.size / 2 / time / 1000]

scanner.reset
time = Benchmark.realtime do
  encoder.encode_stream scanner
end
puts 'Scanning + Encoding: %0.2fs -- %0.0f kTok/s' % [time, (N * 11 + 1) / time / 1000]
