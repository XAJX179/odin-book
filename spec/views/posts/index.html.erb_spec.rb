# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "posts/index.html.erb", type: :view do
  it 'displays a page with loader and no user specific content' do
    render
    expect(rendered).to match(/Loading/)
  end

  it 'has turbo frame for posts' do
    render
    assert_turbo_frame "posts"
  end

  it 'has turbo frame for loader' do
    render
    assert_turbo_frame "loader" do
      assert_select "p", text: "Loading..."
    end
  end
end
