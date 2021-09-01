# rails-recipes

<h3>Description</h3>
  rails recipes - Registration system

Event information that users can see at the front desk
Administrators can manage activity data in the background
Administrators can manage user information in the background
Users can register at the front desk
The administrator can manage newspaper information in the background

<h3>Enviroment</h3>
  rails ~> 5.0.7
  ruby ~> 2.6.5
  vue ^2.5.17
  vuex ^3.0.1
  pg ~> 0.5.3

<h3>Edit</h3> 

``` bash
# copy it to .env
rake secret

# copy database.yml
cp database.yml.example database.yml

# create fake data
rake dev:fake_data

# after create fake data, get root user
email: admin@example.org
password: 12345678
```

<h3>Install</h3> 

``` bash
# install ruby 2.6.5
rvm install ruby 2.6.5

# insall yarn
yarn install

# insall gem files
bundle install

# create db
rake db:create

# create migration database
rake db:migration
```

<h3>Execute and Run</h3> 

``` bash
# path
cd rails-recipes

# excute serve
rails server
```
