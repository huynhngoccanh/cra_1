class CardsController < ApplicationController
  def new
  end

  def create
    @user = current_user

    unless @user.stripe_id.present?
      Stripe::Customer.create(
        :description => "Activate Account",
        :email => @user.email,
        :source  => params[:stripeToken]
      )
    else
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      customer.sources.create(source: params[:stripeToken])
    end

    redirect_to :back
  end

  def destroy
    customer = Stripe::Customer.retrieve(current_user.login_stripe_id)
    customer.sources.retrieve(params[:id]).delete()
    redirect_to :back
  end
end
