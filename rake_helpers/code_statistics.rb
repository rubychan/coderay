# From rails (http://rubyonrails.com)
#
# Improved by murphy
class CodeStatistics

	TEST_TYPES = /\btest/i

	# Create a new Code Statistic.
	#
	# Rakefile Example:
	# 
	#  desc 'Report code statistics (LOC) from the application'
	#  task :stats => :copy_files do
	#    require 'rake_helpers/code_statistics'
	#    CodeStatistics.new(
	#      ["Main", "lib"],
	#      ["Tests", "test"],
	#      ["Demos", "demo"]
	#    ).to_s
	#   end
	def initialize(*pairs)
		@pairs = pairs
		@statistics = calculate_statistics
		@total = if pairs.empty? then nil else calculate_total end
	end

	# Print a textual table viewing the stats
	#
	# Intended for console output.
	def print
		print_header
		@pairs.each { |name, path| print_line name, @statistics[name] }
		print_splitter

		if @total
			print_line 'Total', @total
			print_splitter
		end

		print_code_test_stats
	end

private

	DEFAULT_FILE_PATTERN = /\.rb$/

	def calculate_statistics
		@pairs.inject({}) do |stats, (name, path, pattern)|
			pattern ||= DEFAULT_FILE_PATTERN
			path = File.join path, '*.rb'
			stats[name] = calculate_directory_statistics path, pattern
			stats
		end
	end

	def calculate_directory_statistics directory, pattern = DEFAULT_FILE_PATTERN
		stats = Hash.new 0

		Dir[directory].each do |file_name|
			p "Scanning #{file_name}..." if $DEBUG
			next unless file_name =~ pattern

			lines = codelines = classes = methods = 0
			empty_lines = comment_lines = 0
			comment_block = nil
			
			File.readlines(file_name).each do |line|
				lines += 1
				case line
				when /^=end\s/
					comment_lines += 1
					comment_block = nil
				when comment_block
					comment_lines += 1
				when /^\s*class\b/: classes += 1
				when /^\s*def\b/: methods += 1
				when /^\s*#/: comment_lines += 1
				when /^\s*$/: empty_lines += 1
				when /^=begin\s/
					comment_block = lines
					comment_lines += 1
				end
			end

			codelines = lines - comment_lines - empty_lines

			stats[:lines] += lines
			stats[:codelines] += codelines
			stats[:classes] += classes
			stats[:methods] += methods
			stats[:files] += 1
		end

		stats
	end

	def calculate_total
		total = Hash.new 0
		@statistics.each_value { |pair| pair.each { |k, v| total[k] += v } }
		total
	end

	def calculate_code
		code_loc = 0
		@statistics.each { |k, v| code_loc += v[:codelines] unless k[TEST_TYPES] }
		code_loc
	end

	def calculate_tests
		test_loc = 0
		@statistics.each { |k, v| test_loc += v[:codelines] if k[TEST_TYPES] }
		test_loc
	end

	def print_header
		print_splitter
		puts "| T=Test  Name              | Files | Lines |   LOC | Classes | Methods | M/C | LOC/M |"
		print_splitter
	end

	def print_splitter
		puts "+---------------------------+-------+-------+-------+---------+---------+-----+-------+"
	end

	def print_line name, statistics
		m_over_c = (statistics[:methods] / statistics[:classes]) rescue m_over_c = 0
		loc_over_m = (statistics[:codelines] / statistics[:methods]) - 2 rescue loc_over_m = 0

		if name[TEST_TYPES]
			name = "T #{name}" 
		else
			name = "  #{name}" 
		end

		line = "| %-25s | %5d | %5d | %5d | %7d | %7d | %3d | %5d |" % (
			[name, *statistics.values_at(:files, :lines, :codelines, :classes, :methods)] +
			[m_over_c, loc_over_m] )

		puts line
	end

	def print_code_test_stats
		code = calculate_code
		tests = calculate_tests

		puts "  Code LOC = #{code}     Test LOC = #{tests}     Code:Test Ratio = [1 : #{sprintf("%.2f", tests.to_f/code)}]"
		puts ""
	end
	
end

# Run a test script.
if $0 == __FILE__
	$VERBOSE = true
	CodeStatistics.new(
		['This dir', File.dirname(__FILE__)]
	).print
end
