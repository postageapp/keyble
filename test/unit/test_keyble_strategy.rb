require_relative '../helper'

class TestKeyble < Test::Unit::TestCase
  def test_defaults
    strategy = Keyble::Strategy.new

    assert_equal 0, strategy.return_code
    assert_equal :list, strategy.command
    assert_equal nil, strategy.user
    assert_equal nil, strategy.message
  end

  def test_default_properties_are_frozen
    strategy = Keyble::Strategy.new

    assert_equal :list, strategy.command

    strategy.command = :test

    assert_equal :test, strategy.command    

    strategy = Keyble::Strategy.new

    assert_equal :list, strategy.command
  end
end
