# Daily News Sense API

[![Build Status](https://semaphoreci.com/api/v1/viamarcus/newsroom_api-april-2020/branches/dependabot-bundler-rack-2-2-3/badge.svg)](https://semaphoreci.com/viamarcus/newsroom_api-april-2020)

The objective was to create a news platform that allow for the staff to create, review and publish news, and for users to browse both local and international news, as well as a mobile version of the user client.

All clients make use of roles (journalist, editor, regular user, subscriber) to authorise users on different levels.

The user facing site also features 
* automatic position detection
* live local weather
* ads 
* ability to become a subscriber to access more content
* automatic browser language detection (eng / swe)
* ability to choose between english and swedish UI language
* browsing news by categories such as "economy" and "latest news".


## Authors:

[Ali Erbay](https://github.com/kermit-klein)  
[Steve Watson](https://github.com/designerofthing)  
[Pauline Barnades](https://github.com/PaulineBA)  
[Erik Björn](https://github.com/erikbjoern)  
[Marcus Sjöqvist](https://github.com/viamarcus)  
[Jenny Scherr](https://github.com/jysmys)  


## Clone:

The API connects to the three front end clients, the [web app](https://github.com/kermit-klein/newsroom_client-april-2020), [mobile app](https://github.com/kermit-klein/newsroom_mobile-april-2020) and [staff web app](https://github.com/kermit-klein/newsroom_staff-april-2020). 
To run these apps locally with a live server, you need to clone this repo and run:
* `$ gem install bundler` to install [bundler](https://bundler.io/)
* `$ bundle` to install gems (dependencies)
* `$ rails db:create db:migrate` to set up the database
* `$ rails db:seed` to populate the database with 60 random articles
* `$ rails c` to start the rails console
* In the console, run: `User.create(email: 'user@mail.com', password: 'password123', role: (optional) 'journalist / editor / subscriber')` to create a user directly in the database. There's no GUI for creating staff roles.

## Testing:

The API was developed test driven using [RSpec](https://rspec.info/), [FactoryBot](https://github.com/thoughtbot/factory_bot#readme) and [Coveralls](https://docs.coveralls.io/)

## Additional gems:

* [devise_token_auth](https://github.com/lynndylanhurley/devise_token_auth#readme) for token based authentication
* [stripe-rails](https://github.com/tansengming/stripe-rails#readme) for handling requests to Stripe
* [faker](https://github.com/faker-ruby/faker#readme) for seeding database with random but relevant content
* we also use the service of [picsum photos](https://picsum.photos/) to serve random images for the articles

# Endpoints documentation:

Prefix for all requests >>> **/api**

### **Articles**

#### index

get /articles  
Can take any combination of location: "Sweden"/nil, category: "", page: 3 (if omitted = 1 )
Note that even though "local" and "current" are not article categories, they are valid in this context.
Local will serve mixed category articles that all have the location provided, or if no location provided, serves a mix of articles without location set.
Current serve as without argument, but will limit the responses to include only articles published in the last 24 hours.
Articles are ordered and latest published items are served first. Items are sent in pages of 20 articles
Each response will show which page it came from, and will return either next_page: page+1 if there is more content to load, or `nil` if there are no more articles to load with the used params.
Each request will include articles belonging to your location, or with international relevance.

```
{
    "page": 1,
    "next_page: nil",
    "articles":[
        {"id":1,
        "title":"title1",
        "category":"category1",
        "published_at":"YYYY-MM-dd hh:mm",
        "image":"http://amazon-web-service-thingy",
        "location": "Sweden",
        "international": true
        },
        {"id":2,
        "title":"title2",
        "category":"category2",
        "published_at":"YYYY-MM-dd hh:mm",
        "image":"http://amazon-web-service-thingy",
        "location": "Sweden",
        "international": true
        }
    ]
}
```

#### show

get /articles/:id
:id exists in db gives a 200 response with body:

:body is restricted to 100 characters without user credentials for articles where :premium is true

```
{
  "article": {
    "id": 1,
    "title": "A title",
    "body": "The body",
    "published_at":"YYYY-MM-dd hh:mm",
    "image":"http://amazon-web-service-thingy",
    "premium": false
  }
}
```

:id does not exist in db gives a 404 with body:

```
{
  "message": "Article with id :id could not be found"
}
```

#### create

post /articles **Requires authentication headers!**
Headers need to include the standard { uid: "", client: "", access_token: "", expiry: "", token_type: "Bearer" }
with :title, :body, :image params (:category is available to set, or will default to "other"), gives 200 response with body:
```
{
  "id": :id,
  "message": "Article successfully created!"
}
```
To set location you need 'location': 'Sweden', and if you have that you may choose international true/false.
If location is omitted international will default to true.

with :title,or :body params missing, gives 400 response with body:

```
{
  "message": "Title can't be blank"
}

or

{
  "message": "Body can't be blank"
}

or

{
  "message": "Category can't be blank"
}

or

{
  "message": "Image can't be blank"
}

or, with when trying to be set to an invalid location

{ 
  "message": ":location, not a valid location", 
  "errors": ['Should have a valid location'] 
}
```

### **Admin::Articles**

#### index

get /admin/articles returns only unpublished articles (:published=false)
to editors only
created_at is based on db created_at

```
{
    "articles":[
        {"id":1,
        "title":"title1",
        "category":"category1",
        "created_at":"YYYY-MM-dd hh:mm"
        },
        {"id":2,
        "title":"title2",
        "category":"category2",
        "created_at":"YYYY-MM-dd hh:mm"
        }
    ]
}
```
#### update

put /admin/articles/:id requires params: activity=="PUBLISH" and accepts :category and :premium.
If :category is not a valid category or :premium not a boolean, an error will be returned.
```
Success:
{ message: "Article successfully published!"}, 200
No auth headers:
{ errors: ["You need to sign in or sign up before continuing."]}, 401
Auth headers for non-editor:
{ message: "You are not authorized }, 401
Bad id:
{ message: "Article not published: Couldn't find Article with 'id'=:id"}, 422
Bad params, example:
{ message: "Article not published: 'music' is not a valid category"}, 422
```

#### show

get /admin/articles/:id returns only unpublished articles, 
to editors only

```
"article": 
  {
    "id": 1,
    "title": "title1",
    "body": "body1 body1 body1 body1 body1",
    "category":"category1",
    "image": "http:amazon-image-thing.com",
    "created_at":"YYYY-MM-dd hh:mm"
  }
```

Trying to access an already published article or non-existing article gives error message:
```
  { 
    "message": "This article was already published"
  }
  or
  {
    "message": "Couldn't find Article with 'id'=34534535"
  }
```
### **Login**

All [devise_token_auth endpoints](https://devise-token-auth.gitbook.io/devise-token-auth/usage) are open, only sign in is tested for right now.
post /auth/sign_in
The login response also includes :role, which can be "user", "journalist", "editor".

```
{
    "data":
  {"id":12,
   "email":"mystring@mail.com",
   "provider":"email",
   "uid":"mystring@mail.com",
   "allow_password_change":false,
   "role": "user"
}
```

with wrong password or email

```
{
    "success":false, "errors":["Invalid login credentials. Please try again."]
}
```

### **Subscriber**

Subscription plan via [Stripe](https://stripe.com/docs)
```
Stripe.plan :dns_subscription do |plan|
  plan.name = 'DNS Subscription'
  plan.amount = 50000
  plan.currency = 'usd'
  plan.interval = 'month'
  plan.interval_count = 12
end
```
#### create

post /api/subscriptions, params: { stripeToken: valid_token } **Requires authentication headers!**

200 response - ```{ message: "Transaction was successful" }```

422 responses
 - stripeToken not existing  - ```{ message: "Transaction was NOT successful. There was no token provided..." }```
 - invoice not paid -  ```{ message: "Transaction was NOT successful. You got no money, fool!" }```
