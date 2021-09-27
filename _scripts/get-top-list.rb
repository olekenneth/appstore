require 'net/http'
require 'json'
require './_scripts/search.rb'

url = "https://rss.itunes.apple.com/api/v1/no/ios-apps/top-free/all/10/explicit.json"
uri = URI(url)
response = Net::HTTP.get(uri)
data = JSON.parse(response)['feed']

for i in 0..data['results'].length - 1
  app = data['results'][i]
  id = app['id']
  search(id, '--y')
end
