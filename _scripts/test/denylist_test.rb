# Plain-Ruby acceptance test for the denylist helper. No gems required.
#
# Run:  ruby _scripts/test/denylist_test.rb
#
# Exits non-zero if any check fails.

require_relative '../denylist'

FIXTURE = File.join(__dir__, 'fixtures', 'denylist.yml')
LIST = load_denylist(FIXTURE)

$failures = 0

def check(description, actual, expected)
  if actual == expected
    puts "ok   - #{description}"
  else
    puts "FAIL - #{description} (expected #{expected.inspect}, got #{actual.inspect})"
    $failures += 1
  end
end

# Blocking by bundle id
check('blocks by bundle id',
      denied?({ 'bundleId' => 'com.example.badapp' }, LIST), :bundle_id)
check('bundle id is case-insensitive',
      denied?({ 'bundleId' => 'COM.EXAMPLE.BadApp' }, LIST), :bundle_id)

# Blocking by artist id (the API returns an Integer; the fixture is a YAML integer)
check('blocks by artist id (numeric)',
      denied?({ 'artistId' => 123_456_789 }, LIST), :artist_id)
check('artist id matches string form too',
      denied?({ 'artistId' => '123456789' }, LIST), :artist_id)

# Blocking by artist name
check('blocks by artist name (case-insensitive)',
      denied?({ 'artistName' => 'EKSEMPEL STUDIO AS' }, LIST), :artist_name)
check('artist name is exact, not substring',
      denied?({ 'artistName' => 'Eksempel Studio AS 2' }, LIST), false)

# Allowed apps / no false positives
check('allows an unlisted app',
      denied?({ 'bundleId' => 'com.good.app', 'artistId' => 999, 'artistName' => 'Nice Dev' }, LIST), false)
check('empty fields never match',
      denied?({ 'bundleId' => '', 'artistName' => '' }, LIST), false)

# Robust loading
check('missing denylist file yields empty lists',
      denied?({ 'bundleId' => 'com.example.badapp' }, load_denylist(File.join(__dir__, 'does-not-exist.yml'))), false)

puts ''
if $failures.zero?
  puts 'All checks passed'
else
  warn "#{$failures} check(s) failed"
  exit 1
end
