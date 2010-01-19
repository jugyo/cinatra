require 'singleton'
require 'readline'
require 'cinatra/command'

class Cinatra
  include Singleton

  attr_accessor :exiting

  def initialize
    Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
    Readline.completion_proc = lambda {|text| completion(text) }
    trap("INT") { exit }
  end

  def add_command(name, desc = '', &block)
    name = normalize_as_command_name(name)
    if commands.key?(name)
      puts "Warning: The command '#{name}' will be overridden."
    end
    commands[name] = Command.new(name, desc, &block)
  rescue Exception => e
    handle_error(e)
  end

  def delete_command(name)
    commands.delete(normalize_as_command_name(name))
  end

  def get_command(name)
    commands[name.to_sym]
  end

  def commands
    @commands ||= {}
  end

  def command_names
    commands.keys.map {|i| i.to_s }
  end

  def call(line)
    line = line.strip
    return if line.empty?
    command_name, command_arg = resolve_command_name_and_arg(line)
    unless command_name
      puts "Error: Command not found: #{line}"
    else
      get_command(command_name).call(command_arg)
    end
  rescue Exception => e
    handle_error(e)
  end

  def completion(text)
    commands.keys.map {|i| i.to_s }.grep(/^#{Regexp.quote(text)}/)
  end

  def start
    while !exiting && buf = Readline.readline('> ', true)
      call(buf)
    end
  end

  def exit
    self.exiting = true
  end

  def handle_error(e)
    puts "Error: #{e.message}\n  #{e.backtrace.join("\n  ")}"
  end

  def resolve_command_name_and_arg(line)
    command_names.map {|i| i.split(' ')}.sort_by{|i| i.size}.reverse_each do |command|
      if is_command_match_to_line?(command, line)
        name = command.join(' ').to_sym
        arg = line.split(' ', command.size + 1)[command.size]
        return name, arg
      end
    end
    return nil, nil
  end

  def normalize_as_command_name(name)
    name = name.to_s
    raise ArgumentError, "`#{name}` is invalid for command name." if /^\s*$/ =~ name
    name.strip.gsub(/\s+/, ' ').to_sym
  end

  def is_command_match_to_line?(command, line)
    line.split(' ')[0...command.size] == command
  end

  class << self
    [
      :add_command, :get_command, :delete_command,
      :commands, :start, :call, :command_names, :exit
    ].each do |method|
      class_eval <<-DELIM
        def #{method}(*args, &block)
          instance.#{method}(*args, &block)
        end
      DELIM
    end
  end
end

module Kernel
  def command(name, desc = '', &block)
    Cinatra.add_command(name, desc, &block)
  end
end

command 'exit', 'Exit' do
  Cinatra.exit
end

command 'help', 'Show help'do |arg|
  if arg
    command = Cinatra.get_command(arg)
    if command
      puts command.desc
    end
  else
    commands = Cinatra.commands.values
    max_length = commands.inject(0) {|max, command| [command.name.to_s.size, max].max }
    commands.each do |command|
      puts "#{command.name.to_s.ljust(max_length)}  #{command.desc.split("\n")[0]}"
    end
  end
end

at_exit do
  Cinatra.start if $!.nil?
end
