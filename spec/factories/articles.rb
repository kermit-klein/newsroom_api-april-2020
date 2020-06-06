# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    title { 'this is title' }
    body { 'this is body, lorem ipsum.' * 20 }
    category { 'sport' }
    location {''}
    trait :with_image do
      image { fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'test.jpg'), 'image/jpg') }
    end
    published { true }
    published_at { Time.now }
  end
end
