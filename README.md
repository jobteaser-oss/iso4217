# iso4217

A tiny Ruby library that provides ISO 4217 currency codes and related information. It ships a JSON dataset and a simple API for listing currency codes or iterating over full currency records.

## Installation

Add to your Gemfile and bundle:

```
gem "iso4217-rb"
```

Or install directly:

```
gem install iso4217-rb
```

Requires Ruby 3.0 or newer.

## Quick start

```ruby
require "iso4217"

# Get the list of all ISO 4217 alpha codes (e.g., ["EUR", "USD", ...])
codes = ISO4217.codes

# Iterate over full currency records
ISO4217.currencies.each do |c|
  puts [c.country_name, c.currency_name, c.currency_code].join(" – ")
end
```

## API

- `ISO4217.codes` → `Array<String>`
  - Returns all ISO 4217 currency codes.

- `ISO4217.currencies` → `Array<ISO4217::Currency>`
  - Returns structured currency entries. Each entry is an immutable `Data` object with the following fields:
    - `country_name`
    - `currency_name` (`String`)
    - `currency_code` (`String`)
    - `currency_number` (`Integer`) — numeric code as a string
    - `minor_unit` (`Integer`) — number of minor units (e.g., 2 for cents)
    - `is_fund` (`true | false`) — whether the entry represents a fund

## Versioning

The library exposes `ISO4217::VERSION`, which reflects the publication date of the underlying dataset in `YYYY-MM-DD` format.

## Data file

The dataset is stored at `config/currency_iso.json` within the project and is loaded at runtime by the library.

## Development

### ISO 4217 standard updates
A rake task is provided for updating the dataset, which should be run periodically

### Running tests

```
rake
```
