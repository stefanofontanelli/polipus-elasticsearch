require 'elasticsearch/model'

ENV['POLIPUS_ELASTICSEACH_INDEX_SHARDS']    ||= '1'
ENV['POLIPUS_ELASTICSEACH_INDEX_REPLICAS']  ||= '0'

module Polipus
  module ElasticSearch
    class Page
        include Elasticsearch::Model

        DEFAULT_INDEX_NAME = 'polipus-pages'
        document_type 'polipus_page'
        index_name DEFAULT_INDEX_NAME

        settings(
          index: {
            number_of_shards: ENV['POLIPUS_ELASTICSEACH_INDEX_SHARDS'].to_i,
            number_of_replicas: ENV['POLIPUS_ELASTICSEACH_INDEX_REPLICAS'].to_i
          }
        )
        mapping(_all: { enabled: false }) do
          indexes(
            :id,
            index: :not_analyzed
          )
          indexes(
            :body,
            type: :binary,
            store: (ENV['POLIPUS_ELASTICSEACH_INDEX_STORE_BODY'] ? true : false)
          )
          indexes(
            :code,
            type: :integer
          )
          indexes(
            :depth,
            type: :integer
          )
          indexes(
            :error,
            type: :string
          )
          indexes(
            :fetched,
            type: :boolean
          )
          indexes(
            :fetched_at,
            type: :integer
          )
          indexes(
            :headers,
            type: :binary,
            store: (ENV['POLIPUS_ELASTICSEACH_INDEX_STORE_HEADERS'] ? true : false)
          )
          indexes(
            :links,
            type: :string,
            analyzer: :uax_url_email
          )
          indexes(
            :redirect_to,
            type: :string,
            analyzer: :uax_url_email
          )
          indexes(
            :referer,
            type: :string,
            analyzer: :uax_url_email
          )
          indexes(
            :response_time,
            type: :integer
          )
          indexes(
            :url,
            type: :string,
            analyzer: :uax_url_email
          )
          indexes(
            :user_data,
            type: :binary,
            store: (ENV['POLIPUS_ELASTICSEACH_INDEX_STORE_USER_DATA'] ? true : false)
          )
        end

        def self.client
          __elasticsearch__.client
        end

        def self.count
          client.count(index: index_name, type: document_type)['count'].to_i
        end

        def self.create_index!(name)
          index_name(name) unless name.nil?
          __elasticsearch__.create_index!(index: index_name)
        end

        def self.clear_index!
          client.delete_by_query(
            index: index_name,
             body: { query: { match_all: {} } }
          )
        end

        def self.delete_index!
          client.indices.delete(index: index_name)
        end

        def self.exists?(obj)
          document = process_document(document)
          client.exists?(
            index: index_name,
            type: document_type,
            id: document['id']
          )
        end

        def self.get(obj)
          document = process_document(document)
          response = client.get_source(
            index: index_name,
            type: document_type,
            id: document['id']
          )
          (response.nil? || response.empty?) ? nil : response
        end

        def self.process_document(obj)
          doc = { '_type' => document_type }
          properties.each do |p|
            doc[p.to_s] = obj.respond_to?(p.to_s) ? obj.send(p.to_s) : obj[p.to_s]
          end
          doc.reject { |_, value| value.nil? }
        end

        def self.properties
          mapping.to_hash[document_type.to_sym][:properties].keys.map { |k| k.to_s }
        end

        def self.remove(document, refresh = false)
          document = process_document(document)
          client.delete(
            index: index_name,
            type: document_type,
            id: document['id'],
            refresh: refresh,
            version: document['fetched_at'].to_i,
            version_type: :external
          )
        end

        def self.setup(client_)
          __elasticsearch__.client = client_
        end

        def self.store(document, refresh = false)
          document = process_document(document)
          client.index(
            index: index_name,
            type: document_type,
            id: document['id'],
            body: document,
            refresh: refresh,
            version: document['fetched_at'].to_i,
            version_type: :external
          )
        end

      end

    end
  end
end
