require 'ostruct'

class Keyble::Strategy < OpenStruct
  # == Extensions ===========================================================
  
  # == Constants ============================================================
  
  DEFAULTS = {
    :return_code => 0,
    :command => :list,
    :context => :keys,
    :key => nil,
    :user => nil,
    :groups => nil
  }.freeze

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize
    super(DEFAULTS)
  end
end
