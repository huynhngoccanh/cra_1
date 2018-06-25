class InvoiceDecorator < Draper::Decorator
  delegate_all

  def amount
    object.amount.to_f / 100
  end
end
