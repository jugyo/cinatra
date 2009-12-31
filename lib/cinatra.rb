require 'singleton'
require 'readline'

class Cinatra
  include Singleton

  attr_accessor :exiting

  def add_command(name, &block)
    name = self.class.normalize_as_command_name(name.to_s).to_sym
    raise "command '#{name}' is already exists." if commands.key?(name)
    commands[name] = block
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

  def command_names
    commands.keys.map {|i| i.to_s }
  end

  def call(line)
    line = line.strip
    return if line.empty?
    command_name, command_arg = resolve_command_name_and_arg(line)
    unless command_name
      puts "Command not found!"
    else
      begin
        get_command(command_name).call(command_arg)
      rescue Exception => e
        puts e.message
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
      Cinatra.commands.keys.map {|i| i.to_s }.grep(/#{Regexp.quote(text)}/)
    end

    while !exiting && buf = Readline.readline('> ', true)
      call(buf)
    end
  end

  def exit
    self.exiting = true
  end

  def resolve_command_name_and_arg(line)
    command_names.map {|i| i.split(' ')}.sort_by{|i| i.size}.reverse_each do |command|
      if self.class.is_command_match_to_line?(command, line)
        name = command.join(' ').to_sym
        arg = line.split(' ', command.size + 1)[command.size]
        return name, arg
      end
    end
    return nil, nil
  end

  class << self
    [
      :add_command, :get_command, :delete_command,
      :commands, :start, :call, :command_names,
      :resolve_command_name_and_arg, :exit
    ].each do |method|
      class_eval <<-DELIM
        def #{method}(*args, &block)
          instance.#{method}(*args, &block)
        end
      DELIM
    end

    def normalize_as_command_name(name)
      name.strip.gsub(/\s+/, ' ')
    end

    def is_command_match_to_line?(command, line)
      line.split(' ')[0...command.size] == command
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
