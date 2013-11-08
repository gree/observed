module Observed
  module Hash
    module KeyPathEncoding

      # Decodes the key path such as 'foo.bar' to dig into the hash and returns `hash[:foo][:bar]`
      # @param [Hash] hash The hash to be dug
      # @param [String] key_path The key path which is consisted of one or more keys from the parent-to-child order,
      #                          e.g. 'foo.bar' which is consisted of the keys 'foo' and 'bar' where
      #                          the former is the key for the root hash and the latter if is the key for
      #                          the nested hash in `{foo: {bar: 'the_value'}}`
      # @param [Hash<Symbol,Boolean>] options
      # @option options [Boolean] :create_if_missing when `true` the intermediate hash objects under the consisting keys
      #                                                   in the key path is created automatically.
      #                                                   In other words, you automatically get `{foo:bar:{}}` when the
      #                                                   hash is `{}` and the key_path is `foo.bar.baz`
      # @yield yields the hash to be updated or read and the last key to reach the value at the specified key path
      # @yieldparam [Hash] hash The hash which has the second to the last key in the key_path. e.g. `{bar:1}` where the
      #                         input hash object is `{foo:{bar:1}}` and the key path is 'foo.bar'
      # @yieldparam [String|Symbol] key 'bar' in the example for the parameter `hash` immediately above.
      # @yieldreturn [Object] The return value of this method is the return value of the given block
      # @returns The result of the given block
      def at_key_path_on_hash(hash, key_path, options = {}, &block)
        create_if_missing = options[:create_if_missing]

        if create_if_missing.nil?
          fail "The key :create_if_missing must be exist in #{options}"
        end

        if hash.nil?
          fail 'The hash must not be nil'
        end

        first, *rest = case key_path
                       when Array
                         key_path
                       when String
                         key_path.split(".")
                       when Symbol
                         key_path
                       end
        key_str = first.to_s
        key_sym = first.intern
        key = if hash.key? key_str
                key_str
              else
                key_sym
              end
        if rest.empty?
          block.call hash, key
        else
          child = hash[key]
          if child
            at_key_path_on_hash(child, rest, options, &block)
          elsif create_if_missing
            hash[key] = created = {}
            at_key_path_on_hash(created, rest, options, &block)
          end
        end
      end
    end
  end
end
