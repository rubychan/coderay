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
      if match = scan(/\s+/)
        encoder.text_token match, :space
      elsif match = scan(/\d+/)
        encoder.text_token match, :number
      elsif match = scan(/\w+/)
        encoder.text_token match, :word
      elsif match = scan(/[,.]/)
        encoder.text_token match, :op
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


class Encoder
  
  def setup
    @out = ''
    @opened = []
  end
  
  def finish
    @out
  end
  
  def encode scanner
    setup
    scanner.tokenize self
    finish
  end
  
  def text_token text, kind
    if kind == :space
      @out << text
    else
      text.gsub!(/[)\\]/, '\\\\\0')  # escape ) and \
      @out << kind.to_s << '(' << text << ')'
    end
  end
  
  def begin_group kind
    # @opened << kind
    @out << kind.to_s << '<'
  end
  
  def end_group kind
    # @opened.pop
    @out << '>'
  end
  
end

size = ((ARGV.first || 1).to_f * 1_000_000).to_i  # size

# generate string
code = "2011 alpha, beta, (gamma), delta.\n"
code *= (size.to_f / code.size).ceil
code.slice! size..-1

slice_size = (ARGV[1] || 100).to_i
N = 1

1.times do
  out = Encoder.new.encode(Scanner.new(code))
end

1.times do
2.times do
  threads = []
  seconds = Benchmark.realtime do N.times do
    chunk_offsets = [0]
    code.lines.each_slice slice_size do |lines|
      chunk_offsets << chunk_offsets.last + lines.join.bytesize
    end
    threads.clear
    chunk_offsets.each_cons(2) do |this_chunk, next_chunk|
      threads << Thread.new do
        Thread.current[:out] = Encoder.new.encode Scanner.new(code[this_chunk...next_chunk])
      end
    end
    threads.each(&:join)
    # out = threads.map { |t| t[:out] }.join
  end end
  
  mb = N * size / 1_000_000.0
  puts 'Multi-Threaded: %0.1f MB in %0.2fs = %0.1f MB/s @ %d threads' % [mb, seconds, mb / seconds, threads.size]
end
2.times do
  seconds = Benchmark.realtime do N.times do
    out = Encoder.new.encode(Scanner.new(code))
  end end
  
  mb = N * size / 1_000_000.0
  puts 'Single-Threaded: %0.1f MB in %0.2fs = %0.1f MB/s' % [mb, seconds, mb / seconds]
end
end