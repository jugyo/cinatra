Cinatra
=======

Cinatra is a library for command based console application.
It is like Sinatra.
シーナトラ.

Feature
-----

* Easy to define commands
* Easy to run
* Completion for commands
* Similar to Sinatra :)

Usage
-----

    command 'todos' do |arg|
      show_todos
    end

sub command:

    command 'todo add' do |arg|
      TODOS << arg
    end

write help:

    command 'todos', <<HELP do |arg|
    list todos
    HELP
      ...
    end

Run
-----

    % ruby app.rb

Default Commands
-----

help:

    > help
    help   Show help
    exit   Exit
    ...

exit:

    > exit
    %

Installation
-----

    % gem install cinatra

Copyright
-----

Copyright (c) 2009 jugyo. See LICENSE for details.
