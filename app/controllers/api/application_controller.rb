class Api::ApplicationController < ApplicationController
  layout false
  skip_before_action :authenticate_user!
end
