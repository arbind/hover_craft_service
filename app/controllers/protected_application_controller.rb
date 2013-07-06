class ProtectedApplicationController < ApplicationController
  before_action :ensure_login
end
