# frozen_string_literal: true

class Api::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_is_subscriber?
  before_action :check_stripe_token

  def create
    begin
      customer_id = get_customer(params[:stripeToken])
      subscription = Stripe::Subscription.create({ customer: customer_id, plan: "dns_subscription" })

      test_enviroment?(customer_id, subscription)

      status = Stripe::Invoice.retrieve(subscription.latest_invoice).paid

      if status
        current_user.update_attribute(:role, 'subscriber')
        render json: { message: "Transaction was successful" }
      else
        render_stripe_error('You got no money, fool!')
      end      
    rescue => error
      render_stripe_error(error.message)
    end
  end

  protected

  def check_stripe_token
    if !params[:stripeToken] or params[:stripeToken].empty?
      render_stripe_error('There was no token provided...')
      return
    end
  end

  def user_is_subscriber?
    current_user.subscriber? && render_stripe_error('You are already a subscriber') and return
  end

  def render_stripe_error(error)
    render json: { message: "Transaction was NOT successful. #{error}" }, status: 422
  end

  def get_customer(stripeToken)
    customer = Stripe::Customer.list(email: current_user.email).data.first
    customer ||= Stripe::Customer.create({ email: current_user.email, source: stripeToken })
    customer.id
  end

  def test_enviroment?(customer_id, subscription)
    if Rails.env.test?
      invoice = Stripe::Invoice.create({ customer: customer_id, subscription: subscription.id, paid: true })
      subscription.latest_invoice = invoice.id  
    end
  end
end
