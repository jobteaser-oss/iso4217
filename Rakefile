# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

require "json"
require "rexml/document"
require "open-uri"

task :update_currency_data do
  url = "https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml"

  xml_data = URI.parse(url).open
  doc = REXML::Document.new(xml_data)

  currencies = []
  published_date = doc.elements["ISO_4217"]["Pblshd"]
  puts "Updating currency data (published date: #{published_date})..."

  doc.elements.each("ISO_4217/CcyTbl/CcyNtry") do |currency_element|
    currencies << {
      "country_name" => currency_element.elements["CtryNm"]&.text,
      "currency_name" => currency_element.elements["CcyNm"]&.text,
      "currency_code" => currency_element.elements["Ccy"]&.text,
      "currency_number" => currency_element.elements["CcyNbr"]&.text.to_i,
      "minor_unit" => currency_element.elements["CcyMnrUnts"]&.text.to_i,
      "is_fund" => currency_element.elements["CcyNm"]&.attributes&.[]("IsFund") ? true : false
    }
  end

  File.write("config/currency_iso.json", JSON.pretty_generate(currencies))

  File.open("lib/iso4217/version.rb", "r+") do |f|
    content = f.read
    content.sub!(/VERSION\s*=\s*".*?"/, "VERSION = \"#{published_date}\"")
    f.rewind
    f.write(content)
    f.flush
    f.truncate(f.pos)
  end
end

task :help do
  sh("rake --tasks")
end

task default: :test

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end
