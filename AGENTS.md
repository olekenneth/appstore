# AGENTS.md

Guidance for AI agents and maintainers working on this repository.

## What this repo is

[appstore.no](https://appstore.no) is a Jekyll static site that lists Norwegian
App Store apps. Each app is a page generated from the `_apps/` collection and
enriched with data in `_data/apps/<slug>.json`.

## How apps are added (automated)

`.github/workflows/jekyll.yml` runs weekly (cron) and on push to `master`:

1. `_scripts/get-top-list.rb` — fetches the top-30 free apps for Norway and calls
   `search()` for each.
2. `_scripts/search.rb` — queries the iTunes Search API and writes one
   `_apps/<slug>.md` per result (front matter: `slug`, `title`, `store`,
   `app_id`, `date`, `published`).
3. `_scripts/update.rb` — looks up full data via the iTunes Lookup API and writes
   `_data/apps/<slug>.json`.

The site is then built from the `_apps` collection using `_layouts/apps.html`.

## Denylist — prevent apps from being added

The denylist lives in `_data/denylist.yml` and has three lists:

```yaml
bundle_ids:   []   # matched against app "bundleId"   (exact, case-insensitive)
artist_ids:   []   # matched against app "artistId"   (exact)
artist_names: []   # matched against app "artistName" (exact, case-insensitive)
```

Enforcement is in `_scripts/search.rb` via `denied?(app)` from
`_scripts/denylist.rb`: a matching app is skipped and no files are written.
Adding a single matching entry (any one of the three) is enough to block an app.

**IMPORTANT: the denylist only prevents NEW additions. It does not remove apps
that are already in the repository.**

### Test

`_scripts/test/denylist_test.rb` is a plain-Ruby (no gems) test for the helper:

```sh
ruby _scripts/test/denylist_test.rb
```

## Remove an app that is already listed

Because the denylist does not delete existing files, removing an app is a manual
step:

1. **Find the slug.** It is both the filename and the `slug:` field in
   `_apps/<slug>.md`. If you only know a bundle id, artist id, artist name, or
   title, search the data files:

   ```sh
   grep -rl "com.spotify.client" _data/apps/   # -> _data/apps/<slug>.json
   ```

2. **Delete both files:**

   ```sh
   rm _apps/<slug>.md _data/apps/<slug>.json
   ```

3. **Prevent re-adding.** If the app could come back (e.g. it is on the top-free
   list that the weekly job ingests), also add its bundle id / artist id /
   artist name to `_data/denylist.yml`.

Deleting the files **without** updating the denylist means the app can be
re-added automatically on the next run.
