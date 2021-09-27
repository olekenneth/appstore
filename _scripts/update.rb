require 'net/http'
require 'json'
require 'front_matter_parser'

unsafe_loader = ->(string) { YAML.load(string) }

apps = Dir["_apps/*.md"]
apps.length.times do
  print '.'
end
puts ''

def updateAppData(id, slug)
  url = "https://itunes.apple.com/lookup?country=no&id=#{id}"
  uri = URI(url)
  #puts 'getting ' + url
  response = Net::HTTP.get_response(uri)
  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)

    for i in 0..data['results'].length - 1
      app = data['results'][i]
      id = app['trackId']

      File.open("_data/apps/#{slug}.json", "w") {|f| f.write(app.to_json) }
      print '.' # Everything is ok
    end
  else
    print "-" # Error from API
  end
end

for filename in 0..apps.length - 1
  begin
    parsed = FrontMatterParser::Parser.parse_file(apps[filename], loader: unsafe_loader)
    # puts parsed['slug']
    updateAppData(parsed['app_id'], parsed['slug'])
  rescue Exception => ex
    puts 'filename: ' + apps[filename]
    puts ex
  end
end
