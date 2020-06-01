60.times do
  file = URI.open('https://picsum.photos/800/400')
  categories = ["other", "sport", "local", "politics", "economy", "world", "entertainment"]
  premium = [true, false, false, false]
  article = Article.new(
    title: Faker::Company.bs.capitalize, 
    body: Faker::Lorem.paragraph(sentence_count: 70), 
    category: categories.sample, premium: premium.sample, 
    published: true, 
    published_at: Time.now
  )
  article.image.attach(io: file, filename: 'image.jpg')
  article.save
end