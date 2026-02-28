# Odin Book

Building single page social media site using https://hotwired.dev/

<!-- live at: https://xajx.alwaysdata.net/odin-book -->

## how to run locally:

requirements: rails, bundler gem, sqlite3 or postgresql depending on the branch

1. clone the repo:
    ```sh
      git clone git@github.com:XAJX179/odin-book.git
    ```

1. install gems using bundler:
    ```sh
      bundle install
    ```

1. create,migrate and seed database:
    ```sh
      rails db:create
      rails db:migrate
      rails db:seed:replant
    ```

1. start server:
    ```sh
      rails server
    ```

1. go to https://localhost:3000/

## Info

* Ruby version
  - built using `3.3.5`

* dependencies
  - check `Gemfile`

* Configuration
  - check `config/*`

* Database creation
  ```sh
    rails db:create
  ```

* Database initialization
  ```sh
    rails db:seed:replant
  ```

* How to run the test suite
  ```sh
    bundle exec rspec # tests are inside spec/ dir
  ```

<!-- * Services (job queues, cache servers, search engines, etc.) -->
<!---->
<!-- * Deployment instructions -->
<!---->
<!-- * ... -->
