# The few places where Active Admin 3 and 4 render the same thing differently.
module PageHelpers
  FILTER = '#q_created_at_input'.freeze

  def aa_v4?
    ActiveAdminDateRangePreset.aa_v4?
  end

  def clear_filters_selector
    aa_v4? ? '.filters-form-clear' : '.clear_filters_btn'
  end

  # Text inputs on Active Admin 3, native date inputs on Active Admin 4.
  def field_inputs(scope)
    scope.all('input:not([type="hidden"])')
  end

  def range_in(scope)
    inputs = field_inputs(scope)
    [inputs.first.value, inputs.last.value]
  end
end

RSpec.configure do |config|
  config.include PageHelpers, type: :feature
end
