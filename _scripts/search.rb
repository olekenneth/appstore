require 'net/http'
require 'json'

def search(search, force)
  url = "https://itunes.apple.com/search?country=NO&term=#{search}&entity=software"
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)

    for i in 0..data['results'].length - 1
      app = data['results'][i]
      name = app['trackName'].to_json
      id = app['trackId']
      date = app['currentVersionReleaseDate']
      published = app['releaseDate']
      slug = name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

      if force != '--y'
        puts "Do you want to store #{name}?"
        feedback = gets.chomp
      else
        feedback = 'y'
      end

      if feedback == 'y'
        puts "Storing _apps/#{slug}.md"
        File.open("_apps/#{slug}.md", "w") {|f| f.write("---
layout: apps
slug: #{slug}
title: #{name}
store: apple
app_id: #{id}
date: #{date}
published: #{published}
---
") }
      else
        puts "Ok, NOT storing file"
      end
    end
  else
    puts "Got error code: " + response.code
  end
end

if __FILE__ == $0
  search, force = ARGV
  ARGV.clear
  search(search, force)
end
