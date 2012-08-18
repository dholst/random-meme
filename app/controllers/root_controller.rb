class RootController < ApplicationController
  def index
    @meme = Meme.offset(rand(Meme.count)).first
  end
end
