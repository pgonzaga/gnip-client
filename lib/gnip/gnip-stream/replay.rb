module Gnip
  module GnipStream
    class Replay < Stream

      def initialize(client)
        super
        @url = "https://stream.gnip.com:443/accounts/#{client.account}/publishers/#{client.publisher}/replay/track/#{client.label}.json"
      end
          
      def consume(options={}, &block)
        @client_callback = block if block
        self.on_message(&@client_callback)
        self.connect(options)
      end
    
      def connect(options)
        search_options = {}
        search_options[:fromDate]    = Gnip.format_date(options[:date_from])  if options[:date_from]
        search_options[:toDate]      = Gnip.format_date(options[:date_to])    if options[:date_to]
        stream_url = [self.url, search_options.to_query].join('?')
        EM.run do
          http = EM::HttpRequest.new(stream_url, inactivity_timeout: 45, connection_timeout: 75).get(head: @headers)
          http.stream { |chunk| process_chunk(chunk) }
          http.callback { 
            handle_connection_close(http) 
            EM.stop
          }
          http.errback { 
            handle_error(http)
            EM.stop
          }
        end
      end
      
    end
  end
end