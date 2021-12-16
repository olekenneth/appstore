require 'net/http'
require 'json'
require './_scripts/search.rb'

url = "https://rss.applemarketingtools.com/api/v2/no/apps/top-free/10/apps.json"
uri = URI(url)
response = Net::HTTP.get(uri)
data = JSON.parse(response)['feed']

for i in 0..data['results'].length - 1
  app = data['results'][i]
  id = app['id']
  search(id, '--y')
end
