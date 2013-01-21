require 'open-uri'

class LinksController < ApplicationController
  def index
    @links = Link.all
  end

  def crawl
    links = Link.all
    
    links.each_with_index do |x, index|
      begin
        body = open(x.url).read
        x.update_attribute("content", body)
      rescue
        p "#{index} of #{links.size} error!"
      end
      p "#{index} of #{links.size}"
    end

    render :text=>"crawl......"
  end

  def show
    @link = Link.find(params[:id])
  end
end
