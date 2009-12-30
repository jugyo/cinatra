require 'commander'

command 'sleep' do |arg|
  sleep arg.to_f
end
