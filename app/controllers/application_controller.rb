class ApplicationController < ActionController::Base
  include Localizable

  before_action :authenticate_user!
end
