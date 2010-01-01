class Cinatra
  class Command
    attr_reader :name, :desc, :proc

    def initialize(name, desc = '', &block)
      @name = name
      @desc = desc
      @proc = block
    end

    def call(*args)
      proc.call(*args)
    end
  end
end
