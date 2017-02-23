class ApiTestController < ApplicationController
  def index
    if Rails.env == "production"
      @host_url = "http://soundchat0520.herokuapp.com"
    else
      @host_url = "http://localhost:3000"
    end
  end
end
