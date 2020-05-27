# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    title { 'this is title' }
    body { 'this is body, lorem ipsum.' * 20 }
    category { 'sport' }
  end
end
