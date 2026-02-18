# frozen_string_literal: true

# PostsController
class PostsController < ApplicationController
  before_action :authenticate_user!

  def index; end
end
