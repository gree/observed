require 'observed/key_path_encoding'

module Observed
  class HashFetcher
    include Observed::KeyPathEncoding

    def initialize(hash)
      @hash = hash || fail('The hash must not be nil')
    end

    def [](key_path)
      at_key_path_on_hash @hash, key_path, create_if_missing: false do |h, k|
        h[k]
      end
    end
  end
end
