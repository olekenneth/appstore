# Shared denylist helper used by _scripts/search.rb.
#
# Loads _data/denylist.yml and decides whether a given app (as returned by the
# iTunes Search/Lookup API) should be blocked from being added to the site.
#
# This only prevents NEW additions; it does not remove already-stored apps.
# See AGENTS.md -> "Remove an app that is already listed".

require 'yaml'

DENYLIST_PATH = File.join(__dir__, '..', '_data', 'denylist.yml')

# Reads the denylist file and returns a normalized hash of lookup lists.
# Robust against a missing file, an empty file, or malformed (non-Hash) YAML.
def load_denylist(path = DENYLIST_PATH)
  data = File.exist?(path) ? YAML.load_file(path) : {}
  data = {} unless data.is_a?(Hash)

  {
    bundle_ids:   Array(data['bundle_ids']).compact.map { |v| v.to_s.strip.downcase },
    artist_ids:   Array(data['artist_ids']).compact.map { |v| v.to_s.strip },
    artist_names: Array(data['artist_names']).compact.map { |v| v.to_s.strip.downcase }
  }
end

# Loaded once when this file is required.
DENYLIST = load_denylist

# Returns the reason an app is denied (:bundle_id, :artist_id or :artist_name)
# or false when the app is allowed. Empty/missing app fields never match.
def denied?(app, list = DENYLIST)
  bundle_id   = app['bundleId'].to_s.strip.downcase
  artist_id   = app['artistId'].to_s.strip
  artist_name = app['artistName'].to_s.strip.downcase

  return :bundle_id   if !bundle_id.empty?   && list[:bundle_ids].include?(bundle_id)
  return :artist_id   if !artist_id.empty?   && list[:artist_ids].include?(artist_id)
  return :artist_name if !artist_name.empty? && list[:artist_names].include?(artist_name)

  false
end
