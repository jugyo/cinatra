require 'singleton'
require 'readline'

class Cinatra
  include Singleton

  def add_command(name, &block)
    raise ArgumentError, "invalid command name: #{name}." unless name.to_s =~ /^\w+$/
    raise "command '#{name}' is already exists." if commands.key?(name.to_sym)

    commands[name.to_sym] = block
  end

  def delete_command(name)
    commands.delete(name.to_sym)
  end

  def get_command(name)
    commands[name.to_sym]
  end

  def commands
    @commands ||= {}
  end

  def call(line)
    if /^\s*(\w+)\s+(.*?)\s*$/ =~ line
      command = commands[$1.to_sym]
      unless command
        puts "Command `#{command}` not found!"
      else
        begin
          command.call($2)
        rescue Exception => e
          puts e.message
        end
      end
    end
  end

  def start
    stty_save = `stty -g`.chomp
    trap("INT") do
      begin
        system "stty", stty_save
      ensure
        exit
      end
    end

    Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
    Readline.completion_proc = lambda do |text|
      Cinatra.commands.keys.map{|i| i.to_s}.grep(/#{Regexp.quote(text)}/)
    end

    while buf = Readline.readline('> ', true)
      call(buf)
    end
  end

  class << self
    [:add_command, :get_command, :delete_command, :commands, :start, :call].each do |method|
      class_eval <<-DELIM
        def #{method}(*args, &block)
          instance.#{method}(*args, &block)
        end
      DELIM
    end
  end
end

module Kernel
  def command(name, &block)
    Cinatra.add_command(name, &block)
  end
end

at_exit do
  Cinatra.start
end
