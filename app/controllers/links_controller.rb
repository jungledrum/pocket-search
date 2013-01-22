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

  def search
    keys = params[:key].split
    sql = ""
    keys.each_with_index do |x, index|
      if index == 0
        sql += "(content like '%#{x}%' or title like '%#{x}%')"
      else
        sql += "and (content like '%#{x}%' or title like '%#{x}%')"
      end
    end
    p "="*100
    p sql
    @links = Link.where(sql)
  end
end
