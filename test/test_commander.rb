require 'helper'

class TestCommander < Test::Unit::TestCase
  def Commander.start
    # do nothing
  end

  context 'default' do
    setup do
      Commander.commands.clear
    end

    should 'add command' do
      Commander.add_command('test')
      Commander.commands.key?(:test)
    end

    should "add a command with name as Symbol" do
      Commander.add_command(:test)
      Commander.commands.key?(:test)
    end

    context 'add a command' do
      setup do
        @block = lambda {}
        Commander.add_command('test', &@block)
      end

      should "get a command" do
        assert_equal @block, Commander.get_command('test')
      end

      should "delete a command" do
        Commander.delete_command('test')
        assert_nil Commander.get_command('test')
      end

      should "call the command" do
        mock(@block).call('foo bar')
        Commander.call(' test foo bar ')
      end

      should "not call the command" do
        mock(@block).call('foo bar').times(0)
        Commander.call(' test_ foo bar ')
      end
    end

    should "raise Error when spcify invalid name for command " do
      assert_raise(ArgumentError) { Commander.add_command(' test') {} }
    end

    should "raise Error when add commans with same name" do
      assert_nothing_raised(RuntimeError) { Commander.add_command('test') {} }
      assert_raise(RuntimeError) { Commander.add_command('test') {} }
    end
  end
end
