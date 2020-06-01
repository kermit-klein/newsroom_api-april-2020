# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    title { 'this is title' }
    body { 'this is body, lorem ipsum.' * 20 }
    category { 'sport' }
    location {'Sweden'}
    trait :with_image do
      image { fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'test.jpg'), 'image/jpg') }
    end
  end
end
