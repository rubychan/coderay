require 'strscan'
require 'benchmark'
require 'thread'

class Scanner < StringScanner
  
  def initialize code, range = 0...code.bytesize
    super code
    @start = range.begin
    @stop  = range.end
  end
  
  def tokenize encoder = Tokens.new
    self.pos = @start
    scan_tokens encoder
    encoder
  end
  
protected
  
  def scan_tokens encoder
    until eos?
      if matched = scan(/ +/)
        encoder.text_token matched, :space
      elsif matched = scan(/\n/)
        if pos >= @stop
          # puts "stopped @ #{pos}"
          return
        end
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
    @out
  end
  
  def encode scanner
    setup
    scanner.tokenize self
    finish
  end
  
  # def token content, kind
  #   if content.is_a? ::String
  #     text_token content, kind
  #   elsif content.is_a? ::Symbol
  #     block_token content, kind
  #   else
  #     raise 'Unknown token content type: %p' % [content]
  #   end
  # end
  
  def text_token text, kind
    # @out <<
    #   if kind == :space
    #     text
    #   else
    #     text.gsub!(/[)\\]/, '\\\\\0')  # escape ) and \
    #     "#{kind}(#{text})"
    #   end
  end
  
  # def block_token action, kind
  #   case action
  #   when :begin_group
  #     begin_group kind
  #   when :end_group
  #     end_group kind
  #   else
  #     raise
  #   end
  # end
  
  def begin_group kind
    # @opened << kind
    # @out << "#{kind}<"
  end
  
  def end_group kind
    # @opened.pop
    # @out << '>'
  end
  
end

size = (ARGV.first || 1).to_i * 1_000_000  # size in MB

# generate string
code = "2011 alpha, beta, (gamma), delta.\n"
code *= (size.to_f / code.size).ceil
code.slice! size..-1

slice_size = (ARGV[1] || 100).to_i

3.times do
2.times do
  threads = []
  seconds = Benchmark.realtime do
    chunk_offsets = [0]
    code.lines.each_slice slice_size do |lines|
      chunk_offsets << chunk_offsets.last + lines.join.bytesize
    end
    # p chunk_offsets.size - 1
    chunk_offsets.each_cons(2) do |this_chunk, next_chunk|
      threads << Thread.new do
        Thread.current[:out] = Encoder.new.encode Scanner.new(code, this_chunk...next_chunk)
      end
    end
    threads.each(&:join)
    out = threads.map { |t| t[:out] }.join
  end
  
  mb = size / 1_000_000.0
  puts 'Multi-Threaded: %0.1f MB in %0.2fs = %0.1f MB/s @ %d threads' % [mb, seconds, mb / seconds, threads.size]
end

2.times do
  seconds = Benchmark.realtime do
    out = Encoder.new.encode(Scanner.new(code))
  end
  
  mb = size / 1_000_000.0
  puts 'Single-Threaded: %0.1f MB in %0.2fs = %0.1f MB/s' % [mb, seconds, mb / seconds]
end
end