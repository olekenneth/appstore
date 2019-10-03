require 'net/http'
require 'json'

search, = ARGV
ARGV.clear

url = "https://itunes.apple.com/search?country=NO&term=#{search}&entity=software"
puts url
uri = URI(url)
response = Net::HTTP.get(uri)
data = JSON.parse(response)

for i in 0..data['results'].length - 1
  app = data['results'][i]
  name = app['trackName']
  id = app['trackId']
  date = app['currentVersionReleaseDate']
  published = app['releaseDate']
  slug = name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

  puts "Do you want to store #{name}?"
  feedback = gets.chomp
  #feedback = 'y'
  if feedback == 'y'
    puts "Storing _apps/#{slug}.md"
    File.open("_apps/#{slug}.md", "w") {|f| f.write("---
layout: apps
slug: #{slug}
title: '#{name}'
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
