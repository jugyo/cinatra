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
    end

    should "raise Error when spcify invalid name for command " do
      assert_raise(ArgumentError) { Cinatra.add_command(' test') {} }
    end

    should "raise Error when add commans with same name" do
      assert_nothing_raised(RuntimeError) { Cinatra.add_command('test') {} }
      assert_raise(RuntimeError) { Cinatra.add_command('test') {} }
    end
  end
end
