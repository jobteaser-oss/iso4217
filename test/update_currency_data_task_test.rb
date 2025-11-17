# frozen_string_literal: true

require "test_helper"
require "rake"
require "stringio"
require "rbconfig"

class UpdateCurrencyDataTaskTest < Minitest::Test
  PROJECT_ROOT = File.expand_path("..", __dir__)
  JSON_PATH = File.join(PROJECT_ROOT, "config", "currency_iso.json")
  VERSION_PATH = File.join(PROJECT_ROOT, "lib", "iso4217", "version.rb")

  ISO_XML = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <ISO_4217 Pblshd="2021-03-30">
      <CcyTbl>
        <CcyNtry>
          <CtryNm>FRANCE</CtryNm>
          <CcyNm>Euro</CcyNm>
          <Ccy>EUR</Ccy>
          <CcyNbr>978</CcyNbr>
          <CcyMnrUnts>2</CcyMnrUnts>
        </CcyNtry>

        <CcyNtry>
          <CtryNm>UNITED STATES OF AMERICA (THE)</CtryNm>
          <CcyNm IsFund="true">US Dollar (Next day)</CcyNm>
          <Ccy>USD</Ccy>
          <CcyNbr>997</CcyNbr>
          <CcyMnrUnts>2</CcyMnrUnts>
        </CcyNtry>
      </CcyTbl>
    </ISO_4217>
  XML

  def setup
    @original_json = File.read(JSON_PATH)
    @original_version = File.read(VERSION_PATH)

    Rake.application = Rake::Application.new
    load File.join(PROJECT_ROOT, "Rakefile")
  end

  def teardown
    File.write(JSON_PATH, @original_json)
    File.write(VERSION_PATH, @original_version)
    silence_warnings { load "iso4217/version.rb" }
  end

  def test_update_currency_data_updates_json_and_version_and_restores_files_afterwards
    task = Rake::Task["update_currency_data"]
    task.reenable

    fake_io = StringIO.new(ISO_XML)
    fake_uri = Data.define(:open)[fake_io]

    URI.stub(:parse, fake_uri) do
      capture_io { task.invoke }
    end

    data = JSON.parse(File.read(JSON_PATH))
    assert_kind_of Array, data
    refute_empty data

    assert_equal 2, data.size

    eur = data.find { |h| h["currency_code"] == "EUR" }
    usd = data.find { |h| h["currency_code"] == "USD" }

    refute_nil eur
    refute_nil usd

    assert_equal "FRANCE", eur["country_name"]
    assert_equal "Euro", eur["currency_name"]
    assert_equal 978, eur["currency_number"]
    assert_equal 2, eur["minor_unit"]
    assert_equal false, eur["is_fund"]

    assert_equal "UNITED STATES OF AMERICA (THE)", usd["country_name"]
    assert_equal "US Dollar (Next day)", usd["currency_name"]
    assert_equal 997, usd["currency_number"]
    assert_equal 2, usd["minor_unit"]
    assert_equal true, usd["is_fund"]

    silence_warnings { load "iso4217/version.rb" }
    assert_equal "2021-03-30", ISO4217::VERSION
  end
end
