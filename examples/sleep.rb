require 'cinatra'

command 'sleep' do |arg|
  sleep arg.to_f
end
