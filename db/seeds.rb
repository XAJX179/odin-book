# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?

  user_attrs = [
    { name: 'xajx',  email: 'xajx@gmail.com' },
    { name: 'xplo',  email: 'xplo@gmail.com' },
    { name: 'viena', email: 'viena@gmail.com' },
    { name: 'noob',  email: 'noob@gmail.com' },
    { name: 'hit',   email: 'hit@gmail.com' },
    { name: 'miss',  email: 'miss@gmail.com' },
    { name: 'mosh',  email: 'mosh@gmail.com' },
    { name: 'kochi', email: 'kochi@gmail.com' },
    { name: 'lamb',  email: 'lamb@gmail.com' },
    { name: 'zero',  email: 'zero@gmail.com' },
    { name: 'hiss',  email: 'hiss@gmail.com' }
  ]

  user_attrs.each do |attr|
    user = User.where(email: attr[:email]).first_or_initialize
    user.name ||= attr[:name]
    user.password ||= Devise.friendly_token[0, 20]
    user.confirmed_at ||= Time.current
    user.save!
  end

  users = User.all

  users.each do |user|
    2.times do |i|
      Post.find_or_create_by!(
        user: user,
        title: "Post #{i + 1} by #{user.name}",
        body: "This is a sample post created by #{user.name}"
      )
    end
  end

  posts = Post.all

  posts.each do |post|
    (users - [ post.user ]).sample(2).each do |user|
      PostLike.find_or_create_by!(
        post: post,
        user: user
      )

      comment = PostComment.find_or_create_by!(
        post: post,
        user: user,
        body: "Nice post #{post.user.name}!"
      )

      second_comment = PostComment.find_or_create_by!(
        post: post,
        user: post.user,
        parent: comment,
        body: "Thanks #{user.name}!"
      )

      PostComment.find_or_create_by!(
        post: post,
        user: user,
        parent: second_comment,
        body: " :) bye ! #{post.user.name}!"
      )
    end
  end

  FriendRequest.find_or_create_by!(
    from: users.first,
    to: users.last
  )

  Friendship.find_or_create_by!(user: users.first, friend: users.last)
  Friendship.find_or_create_by!(user: users.last, friend: users.first)
end
