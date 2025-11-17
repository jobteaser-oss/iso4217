# frozen_string_literal: true

require "bundler/setup"
require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

def silence_warnings
  original_verbose = $VERBOSE
  $VERBOSE = nil
  yield
ensure
  $VERBOSE = original_verbose
end
