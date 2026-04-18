require 'rails_helper'

RSpec.describe "Users", type: :request do
  context "with signed in user" do
    describe "#index" do
      it "renders index" do
        user = create(:user)
        sign_in user
        get users_url
        expect(response).to have_http_status(200).and render_template(:index)
      end
    end
    describe '#show' do
      it "renders show" do
        user = create(:user)
        sign_in user
        get user_profile_url(user)
        expect(response).to have_http_status(200).and render_template(:show)
      end
    end
    describe '#edit' do
      it "renders edit" do
        user = create(:user)
        sign_in user
        get edit_user_profile_url(user)
        expect(response).to have_http_status(200).and render_template(:edit)
      end
    end
    describe '#update' do
      it "redirects to profile page" do
        user = create(:user)
        sign_in user
        put user_profile_url(user_id: user.id), params: { profile: { display_name: "", about: "" } }
        expect(response).to have_http_status(303).and redirect_to(user_profile_url)
      end
      it "updates profile" do
        user = create(:user)
        sign_in user
        put user_profile_url(user_id: user.id), params: { profile: { display_name: "abcd100", about: "" } }
        user.reload
        expect(user.profile.display_name).to eq("abcd100")
      end
    end
    describe '#load_all' do
      it "sends turbo stream" do
        user = create(:user)
        sign_in user
        get load_all_users_url(format: "turbo_stream")
        expect(response).to have_http_status(200)
        assert_turbo_stream(action: "replace", target: "users-loader")
        assert_turbo_stream(action: "append", target: "users")
      end
    end
    describe '#search' do
      it 'returns result' do
        user = create(:user)
        sign_in user
        get search_users_url(name: 'user')
        expect(response).to have_http_status(200).and render_template(:search)
        assert_select("#search-results")
      end
    end
    describe '#profile_buttons' do
      context 'for current user' do
        it 'returns no profile button partial' do
          user = create(:user)
          sign_in user
          get buttons_of_user_profile_url(user)
          expect(response).to have_http_status(200).and render_template('users/_buttons')
          assert_turbo_frame("user_#{user.id}_profile_action_button")
        end
      end
      context 'for other user' do
        it 'returns profile button partial' do
          user = create(:user)
          user1 = create(:user)
          sign_in user
          get buttons_of_user_profile_url(user1)
          expect(response).to have_http_status(200).and render_template('users/_buttons')
          assert_turbo_frame("user_#{user1.id}_profile_action_button")
        end
      end
    end
  end
end
