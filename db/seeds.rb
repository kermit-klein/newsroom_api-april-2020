60.times do
  file = URI.open('https://picsum.photos/800/400')
  categories = ["other", "sport", "politics", "economy", "world", "entertainment"]
  premium = [true, false, false, false]
  locations = ['Sweden', nil]
  location = locations.sample
  article = Article.new(
    title: Faker::Company.bs.capitalize, 
    body: Faker::Lorem.paragraph(sentence_count: 70), 
    category: categories.sample, premium: premium.sample, 
    published: true, 
    published_at: Time.now - rand*200000,
    location: location,
    international: location ? [true,false].sample : true
  )
  article.image.attach(io: file, filename: 'image.jpg')
  article.save
end