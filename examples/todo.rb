require 'cinatra'

TODOS = []

def show_todos
  TODOS.each_with_index do |todo, index|
    puts "#{index}: #{todo}"
  end
end

command 'todo add' do |arg|
  TODOS << arg
  show_todos
end

command 'todo delete' do |arg|
  TODOS.delete_at(arg.to_i)
  show_todos
end

command 'todo list' do |arg|
  show_todos
end

command 'todo clear' do |arg|
  TODOS.clear
end
