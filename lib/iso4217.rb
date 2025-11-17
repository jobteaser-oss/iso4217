# frozen_string_literal: true

require "json"
require_relative "iso4217/version"

module ISO4217

  Currency = Data.define(
    :country_name,
    :currency_name,
    :currency_code,
    :currency_number,
    :minor_unit,
    :is_fund
  )

  def self.currencies
    @currencies ||= load_currency_data
  end

  def self.codes
    currencies.map(&:currency_code).compact
  end

  def self.load_currency_data
    json_path = File.expand_path("../../config/currency_iso.json", __FILE__)
    JSON.parse(File.read(json_path)).map do |currency_data|
      Currency.new(
        country_name: currency_data["country_name"],
        currency_name: currency_data["currency_name"],
        currency_code: currency_data["currency_code"],
        currency_number: currency_data["currency_number"],
        minor_unit: currency_data["minor_unit"],
        is_fund: currency_data["is_fund"]
      )
    end
  end
  private_class_method :load_currency_data
end
