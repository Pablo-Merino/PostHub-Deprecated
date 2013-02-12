# PostHub

**Warning! This project is discontinued and no support will be provided!**

In order to get it working, you'll need a Twitter consumer and secret and set them in `application.rb` in line 42-43:

```ruby
 config.twitter_login = Twitter::Login.new \
        :consumer_key => 'CONSUMER', :secret => 'SECRET'
```

And in controllers/blog_controller.rb on line 52

```ruby
:consumer_key=>'CONSUMER', :consumer_secret=>'SECRET'
```

You'll also need a MongoDB server.