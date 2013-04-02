
require 'fileutils'
require 'tempfile'
require 'ipaddr'

class Hosts_alias
	HOSTS_PATH = "/etc/hosts"
	def initialize(arguments)
		@args = []
		@alias
		@ip = "127.0.0.1"
		@add_or_remove = :+
		
		get_args arguments
		parse_arg @args[0]

		case @add_or_remove
		when :+
			puts "added alias(#{@alias}) for #{@ip}"
		when :-
			puts "removed alias(#{@alias}) for #{@ip}"
		end
		editing_hosts
	end
	
	private
	def get_args(arguments)
		arguments.each do|a|
			@args << a
		end
		raise StandardError.new "too many arguments" if @args.size > 1
		raise StandardError.new "too few arguments" if @args.size <= 0
	end

	def parse_arg(arg)
		if arg[0] == "+" || arg[0] == "-"
			@add_or_remove = arg[0].to_sym
			arg = arg[1...arg.size]
		end
		@alias = arg
		if arg.match /\//
			splits = arg.split /\//
			@alias = splits[0]
			@ip = splits[1]
			if (IPAddr.new(@ip) rescue nil).nil?
            	raise StandardError.new "invalid ip"
			end
		end
		
    end

    def editing_hosts
    	# Open temporary file
		tmp = Tempfile.new("tmp_hosts")

		# Write good lines to temporary file
		found = false
		open(HOSTS_PATH, 'r').each { |l| 
			if l.match /#{@ip}.#{@alias}/
				tmp << l unless @add_or_remove == :-
				found = true
			else
				tmp << l 
			end
		 }

		tmp << "\n#{@ip}\t#{@alias}" if (@add_or_remove == :+ && !found)
		
		# Close tmp, or troubles ahead
		tmp.close

		FileUtils.chmod 644, tmp.path # fix permissions		
		FileUtils.mv tmp.path, HOSTS_PATH # Move temp file to origin

    	
    end
end
