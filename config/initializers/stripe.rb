# frozen_string_literal: true

Stripe.plan :dns_subscription do |plan|
  plan.name = 'DNS Subscription 2'
  plan.amount = 50_000
  plan.currency = 'usd'
  plan.interval = 'month'
  plan.interal_count = 12
end
