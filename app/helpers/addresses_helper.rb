module AddressesHelper
  def states_for_select(selected = nil)
    states = Address::STATES.map{ |k, v| [v, k] }

    options_for_select(states, selected)
  end
end
