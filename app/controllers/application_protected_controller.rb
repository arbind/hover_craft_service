class ApplicationProtectedController < ApplicationController
  layout 'application_protected'
  before_action :ensure_login
end
