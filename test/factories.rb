require 'factory_girl'

# This will guess the User class
Factory.define :user do |u|
  u.login 'John'
  u.email 'joe@example.com'
end