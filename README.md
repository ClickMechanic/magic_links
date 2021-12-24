# MagicLinks

Send 'magic links' to your users that grants them authorized access to your application without the need for them to be signed in.

#### Features:

- Grant authorized access to a subset of controllers and actions only
- Set an expiry time on the magic link
- Quick and easy to implement via the use of magic link 'templates' and inbuilt url helpers
- Negligible performance overhead

## Requirements
This gem assumes you are using Devise for authentication, and already have it installed and configured. If you have not done so, then follow their setup instructions here: https://github.com/heartcombo/devise#getting-started

It also requires that your application is using cookies.

## Installation

1. Add this line to your application's Gemfile:

```ruby
gem 'magic_links'
```

2. Install the gem
```bash
$ bundle install
```

3. Copy across the magic link migrations and run them
```bash
rails magic_links:install:migrations
rails db:migrate
```

4. Add the magic_link authentication strategy to your Devise configuration. For example, to enable magic_link authentication for 'users':

#### /config/initializers/devise.rb:
```ruby
config.warden do |manager|
  # adds magic_token_authentication before the devise defaults
  manager.default_strategies(scope: :user).unshift :magic_token_authentication
end
```

### Usage

To start creating magic links, you first need to specify one or more 'templates'. It is recommended that you do this by creating a magic_links initializer:

#### /config/initializers/magic_links.rb:
Example:
```ruby
# This will enable the helper:
# `magic_link_for(current_user, :order_tracking, '/orders/12345/tracking')`, which will return a relative path, or
# `magic_url_for(current_user, :order_tracking, '/orders/12345/tracking')`, which will return a a full URL.
# the resulting path/URL (e.g. `/ot/abcd12345`) will redirect to `/orders/12345/tracking`,
# authenticating `current_user` to perform any actions permitted in the `action_scope`. 
# In this case, the user can call the 'show' and 'edit' actions on the 'Orders::TrackingController' and the 'dashboard'
# action on 'CustomersController'

Rails.application.config.to_prepare do
  MagicLinks.add_template(
      name: :order_tracking,
      pattern: '/ot/:token',
      action_scope: {'orders/tracking': [:show, :edit], customers: :dashboard},
      strength: :mild # mild (8 char strength), moderate (16), or strong (32)
  )
 end
```

The templates can then be used as arguments to the url helpers. For example, to generate a magic link that can be sent 
to a user:

```ruby
magic_link_for(current_user, :order_tracking, order_tracking_path, expiry: 1.week.from_now) 
# will output '/ot/abcd1234'
```

Note: If a user attempts to perform an action that isn't part of the magic token's scope, they will receive a 401 and, 
with Devise's default behavior will be redirected to a sign in page.

### Magic Links Helper
By default, the magic_links helper is included in `ActionController`. If you would like to use the magic_links helpers 
anywhere else (e.g. in views) then you can simply include the helper manually.
e.g:
```ruby
module ApplicationHelper
  include MagicLinks::MagicLinksHelper
  ...
end
```

### Default url options
When using the `magic_url_for` helper you'll need to specify default_url_options for your development and testing
environments.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
