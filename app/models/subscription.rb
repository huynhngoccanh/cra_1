class Subscription < ActiveRecord::Base
  belongs_to :user

  def plan
    SignupStripePlan.find_by(plan_id: plan_id)
  end

  def purchase!
    return false if subscription_id.present?
    subscription = Stripe::Subscription.create(
      :customer => user.stripe_id,
      :items => [{ :plan => plan_id }]
    )
    self.update(
      subscription_id: subscription.id
    )

    create_invoice(subscription)
  end

  private

  def create_invoice(subscription)
    Invoice.create(
      invoice_id: subscription.id,
      currency: 'USD',
      amount: plan.amount,
      start_date: Time.at(subscription.current_period_start).to_datetime.strftime("%d-%m-%Y"),
      end_date: Time.at(subscription.current_period_end).to_datetime.strftime("%d-%m-%Y"),
      customer_id: subscription.customer,
      pay_status: true
    )

    # InvoiceMailer.send_invoice(user)
  end
end
