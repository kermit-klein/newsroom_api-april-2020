# frozen_string_literal: true

class Api::SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:stripeToken] && !params[:stripeToken].empty?
      begin
        customer_id = get_customer(params[:stripeToken])
        subscription = Stripe::Subscription.create({ customer: customer_id, plan: "dns_subscription" })

        Rails.env.test? && test_env(customer_id, subscription)
        payment_status(subscription)
      rescue => error
        render json: { message: "Transaction was NOT successful. #{error.message}" }, status: 422
      end
    else
      render json: { message: "Transaction was NOT successful. There was no token provided..." }, status: 422
    end
  end

  def get_customer(stripeToken)
    customer = Stripe::Customer.list(email: current_user.email).data.first
    customer ||= Stripe::Customer.create({ email: current_user.email, source: stripeToken })
    customer.id
  end

  def test_env(customer_id, subscription)
    invoice = Stripe::Invoice.create({ customer: customer_id, subscription: subscription.id, paid: true })
    subscription.latest_invoice = invoice.id
  end

  def payment_status(subscription)
    status = Stripe::Invoice.retrieve(subscription.latest_invoice).paid

    if status
      current_user.update_attribute(:subscriber, true)
      render json: { message: "Transaction was successful" }
    else
      render json: { message: "Transaction was NOT successful. You got no money, fool!" }, status: 422
    end
  end
end
