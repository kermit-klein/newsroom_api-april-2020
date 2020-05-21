FactoryBot.define do
  factory :user do
    email { "MyString@mail.com" }
    password { "MyString" }
    password_confirmation { "MyString" }
  end
end
