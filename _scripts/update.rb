require 'net/http'
require 'json'
require 'front_matter_parser'

unsafe_loader = ->(string) { YAML.load(string) }

apps = Dir["_apps/*.md"]
apps.length.times do
  print '.'
end
puts ''

def updateAppData(id)
  url = "https://itunes.apple.com/lookup?country=no&id=#{id}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  for i in 0..data['results'].length - 1
    app = data['results'][i]
    name = app['trackName']
    id = app['trackId']
    slug = name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

    print '.'
    File.open("_data/apps/#{slug}.json", "w") {|f| f.write(app.to_json) }
  end
end

for filename in 0..apps.length - 1
  parsed = FrontMatterParser::Parser.parse_file(apps[filename], loader: unsafe_loader)
  updateAppData(parsed['app_id'])
end
