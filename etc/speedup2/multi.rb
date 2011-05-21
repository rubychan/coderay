require 'strscan'
require 'benchmark'
require 'thread'

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
      elsif matched = scan(/=/)  #/
        encoder.text_token matched, :not_going_to_happen
      elsif matched = scan(/%/)
        encoder.text_token matched, :not_going_to_happen
      elsif matched = scan(/\d+/)
        encoder.text_token matched, :number
      elsif matched = scan(/\w+/)
        encoder.text_token matched, :word
      elsif matched = scan(/[,.]/)
        encoder.text_token matched, :op
      elsif scan(/\(/)
        encoder.begin_group :par
      elsif scan(/\)/)
        encoder.end_group :par
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
  def begin_group kind; push :begin_group, kind end
  def end_group kind; push :end_group, kind end
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
  
  def encode scanner
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
    when :begin_group
      begin_group kind
    when :end_group
      end_group kind
    else
      raise
    end
  end
  
  def begin_group kind
    @opened << kind
    @out << "#{kind}<"
  end
  
  def end_group kind
    @opened.pop
    @out << '>'
  end
  
end

N = (5 ** (ARGV.first || 8).to_i)
code = (1..N).map { |n| "#{n} alpha, beta, (gamma).\n" }.join

slice_size = (ARGV[1] || 100).to_i
3.times do
  time = Benchmark.realtime do
    threads = []
    code.lines.each_slice slice_size do |lines|
      threads << Thread.new do
        Thread.current[:out] = Encoder.new.encode(Scanner.new(lines.inject(&:+)))
      end
    end
    threads.each(&:join)
    out = threads.map { |t| t[:out] }.join
  end
  puts 'Multi-Threaded: %0.2fs -- %0.0f kTok/s' % [time, (N * 11 + 1) / time / 1000]
end

3.times do
  time = Benchmark.realtime do
    out = Encoder.new.encode(Scanner.new(code))
  end
  puts 'Current: %0.2fs -- %0.0f kTok/s' % [time, (N * 11 + 1) / time / 1000]
end
