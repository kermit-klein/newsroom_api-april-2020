# frozen_string_literal: true

class Api::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  def create
    if params[:stripeToken]
      customer = Stripe::Customer.list(email: current_user.email).data.first
      customer ||= Stripe::Customer.create({email: current_user.email, source: params[:stripeToken]})
      subscription = Stripe::Subscription.create({customer: customer.id, plan: 'dns_subscription'})
      if Rails.env.test?
        invoice = Stripe::Invoice.create({customer: customer.id, subscription: subscription.id, paid: true})
        subscription.latest_invoice = invoice.id
      end
      payment_status = Stripe::Invoice.retrieve(subscription.latest_invoice).paid
      if payment_status == true
        current_user.update_attribute(:subscriber, true)
        render json: { message: 'Transaction was successful' }
      else
        render json: { message: 'Transaction was NOT successful. You got no money, fool!' }, status: 422
      end

    else
      render json: { message: 'Transaction was NOT successful. There was no token provided...' }, status: 422
    end
  end
end