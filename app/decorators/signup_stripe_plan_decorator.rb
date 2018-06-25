class SignupStripePlanDecorator < Draper::Decorator
  delegate_all

  def price
    "$#{object.amount / 100}"
  end
end
