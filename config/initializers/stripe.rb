# frozen_string_literal: true

Stripe.plan :dns_subscription do |plan|
  plan.name = 'DNS Subscription'
  plan.amount = 50000
  plan.currency = 'usd'
  plan.interval = 'month'
  plan.interval_count = 12
end
