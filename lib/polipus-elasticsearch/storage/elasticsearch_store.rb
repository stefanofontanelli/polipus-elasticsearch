# encoding: UTF-8
require 'cassandra'
require 'multi_json'
require 'polipus'
require 'thread'
require 'zlib'

module Polipus
  module Storage
    class ElasticSearchStore < Base
      BINARY_FIELDS = %w(body headers user_data)
      DEFAULT_INDEX = Polipus::ElasticSearch::Page

      attr_accessor :index, :index_name, :except, :compress, :semaphore

      def initialize(client, options = {})
        @index = options[:index] || options['index'] || DEFAULT_INDEX
        @index_name = options[:index_name] || options['index_name']
        @except = options[:except] || options['except'] || []
        @compress = options[:compress] || options['compress']
        @semaphore = Mutex.new
        index.setup(client)
        index.create_index!(index_name) unless index.client.indices.exists?(index: index_name)
      end

      def add(page)
        semaphore.synchronize do
          obj = page.to_hash
          Array(except).each { |field| obj.delete(field.to_s) }
          BINARY_FIELDS.each do |field|
            next if obj[field.to_s].nil?
            obj[field.to_s] = Zlib::Deflate.deflate(obj[field.to_s])
          end
        end
      end

      def clear
        index.clear_index!
      end

      def count
        index.count
      end

      def each
        raise 'NotImplemented'
      end

      def exists?(page)
        @semaphore.synchronize do
          index.exists?(page)
        end
      end

      def get(page)
        @semaphore.synchronize do
          load_page(index.get(page))
        end
      end

      def remove(page)
        @semaphore.synchronize do
          index.remove(page)
        end
      end

      def load_page(data)
        return nil if data.nil?
        BINARY_FIELDS.each do |field|
          next if data[field.to_s].nil?
          data[field.to_s] = Zlib::Inflate.inflate(data[field.to_s])
        end
        page = Page.from_hash(data)
        page.fetched_at ||= 0
        page
      end
    end
  end
end
