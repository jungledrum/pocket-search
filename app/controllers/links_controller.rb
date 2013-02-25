class LinksController < ApplicationController
  def index
    @links = Link.all
  end

  def show
    @link = Link.find(params[:id])
  end

  def search
    keys = params[:key].split
    sql = "left join items ON items.link_id = links.id where items.user_id=#{session[:uid]}"
    keys.each_with_index do |x, index|
      sql += " and (links.content like '%#{x}%' or links.title like '%#{x}%')"
    end
    p "="*80
    p sql
    @user = User.find(session[:uid])
    @links = Link.joins(sql)
    # @links = Link.where(sql)
  end
end
