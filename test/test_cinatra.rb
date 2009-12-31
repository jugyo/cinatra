require 'helper'

class TestCinatra < Test::Unit::TestCase
  def Cinatra.start
    # do nothing
  end

  context 'default' do
    setup do
      Cinatra.commands.clear
    end

    should 'add command' do
      Cinatra.add_command('test')
      Cinatra.commands.key?(:test)
    end

    should "add a command with name as Symbol" do
      Cinatra.add_command(:test)
      Cinatra.commands.key?(:test)
    end

    context 'add a command' do
      setup do
        @block = lambda {}
        Cinatra.add_command('test', &@block)
      end

      should "get a command" do
        assert_equal @block, Cinatra.get_command('test')
      end

      should "delete a command" do
        Cinatra.delete_command('test')
        assert_nil Cinatra.get_command('test')
      end

      should "call the command" do
        mock(@block).call('foo bar')
        Cinatra.call(' test foo bar ')
      end

      should "not call the command" do
        mock(@block).call('foo bar').times(0)

        $stdout = StringIO.new
        Cinatra.call(' test_ foo bar ')
        $stdout = STDOUT
      end

      should 'resolve command name' do
        assert_equal [:test, nil],         Cinatra.resolve_command_name_and_arg('test')
        assert_equal [:test, 'foo'],       Cinatra.resolve_command_name_and_arg('test foo')
        assert_equal [:test, 'foo bar'],   Cinatra.resolve_command_name_and_arg('test foo bar')
        assert_equal [:test, 'foo  bar'],  Cinatra.resolve_command_name_and_arg('test foo  bar')
      end

      context "add a command 'test foo'" do
        setup do
          @block_foo = lambda {}
          Cinatra.add_command('test foo', &@block_foo)
        end

        should "call command 'test'" do
          mock(@block).call('bar')
          Cinatra.call('test bar')
        end

        should "call command 'test foo'" do
          mock(@block).call.with_any_args.times(0)
          mock(@block_foo).call(nil)
          Cinatra.call('test foo')
          mock(@block_foo).call('a b')
          Cinatra.call('test foo a b')
        end

        context "add a command 'test foo bar'" do
          setup do
            @block_foo_bar = lambda {}
            Cinatra.add_command('test foo bar', &@block_foo_bar)
          end

          should "call command 'test foo bar'" do
            mock(@block).call.with_any_args.times(0)
            mock(@block_foo).call.with_any_args.times(0)
            mock(@block_foo_bar).call(nil)
            Cinatra.call('test foo bar')
            mock(@block_foo_bar).call('a b')
            Cinatra.call('test foo bar a b')
          end
        end
      end
    end

    should "check to match command to line" do
      assert Cinatra.is_command_match_to_line?(['test'], 'test') == true
      assert Cinatra.is_command_match_to_line?(['test'], ' test ') == true
      assert Cinatra.is_command_match_to_line?(['test'], 'te st') == false
      assert Cinatra.is_command_match_to_line?(['test'], 'tes') == false
      assert Cinatra.is_command_match_to_line?(['test', 'foo'], 'test foo') == true
      assert Cinatra.is_command_match_to_line?(['test', 'foo'], ' test  foo ') == true
      assert Cinatra.is_command_match_to_line?(['test', 'bar'], ' test  foo ') == false
      assert Cinatra.is_command_match_to_line?(['test', 'foo'], 'foo test') == false
      assert Cinatra.is_command_match_to_line?(['test', 'foo', 'bar'], 'test foo bar') == true
    end

    should "normalize as command name" do
      assert_equal 'test', Cinatra.normalize_as_command_name('test')
      assert_equal 'test', Cinatra.normalize_as_command_name(' test ')
      assert_equal 'test foo', Cinatra.normalize_as_command_name('test foo')
      assert_equal 'test foo', Cinatra.normalize_as_command_name(' test  foo ')
      assert_equal '', Cinatra.normalize_as_command_name('')
    end

    should "raise Error when add commans with same name" do
      assert_nothing_raised(RuntimeError) { Cinatra.add_command('test') {} }
      assert_raise(RuntimeError) { Cinatra.add_command('test') {} }
    end
  end
end
