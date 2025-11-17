# frozen_string_literal: true

require "test_helper"
require "iso4217"

class ISO4217Test < Minitest::Test
  def test_version_exists
    refute_nil ::ISO4217::VERSION
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, ::ISO4217::VERSION)
  end

  def test_codes_returns_array
    assert_kind_of Array, ISO4217.codes
    refute_empty ISO4217.codes
  end

  def test_common_codes_include_eur_and_usd
    codes = ISO4217.codes
    assert_includes codes, "EUR"
    assert_includes codes, "USD"
  end

  def test_currencies_include_france
    currencies = ISO4217.currencies
    assert_kind_of Array, currencies
    refute_empty currencies

    has_france = currencies.any? do |c|
      c.country_name == "FRANCE" && c.currency_code == "EUR" && c.currency_name == "Euro"
    end

    assert has_france, "Expected currencies to include France with Euro (EUR)"
  end
end
