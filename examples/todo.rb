require 'cinatra'

TODOS = []

def show_todos
  TODOS.each_with_index do |todo, index|
    puts "#{index}: #{todo}"
  end
end

command 'todo add', <<DESC do |arg|
Add a todo to list
usage: todo add buy the milk
DESC
  TODOS << arg
  show_todos
end

command 'todo delete', 'Delete a todo from list' do |arg|
  TODOS.delete_at(arg.to_i)
  show_todos
end

command 'todo list', 'Show todo list' do |arg|
  show_todos
end

command 'todo clear', 'Clear todo list' do |arg|
  TODOS.clear
end
