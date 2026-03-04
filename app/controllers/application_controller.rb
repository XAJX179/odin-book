# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name email])
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :login ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :login ])
  end
end
