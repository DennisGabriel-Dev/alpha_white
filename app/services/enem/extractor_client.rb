require "json"
require "net/http"
require "tempfile"

module Enem
  class ExtractorClient
    class Error < StandardError; end

    DEFAULT_TIMEOUT_SECONDS = 60

    def initialize(base_url: ENV.fetch("ENEM_EXTRACTOR_URL", "http://enem_extractor:8000"), timeout: DEFAULT_TIMEOUT_SECONDS)
      @base_url = base_url
      @timeout = timeout
    end

    def extract(exam_pdf_attachment:, answer_key_pdf_attachment:)
      with_attachment_tempfile(exam_pdf_attachment) do |exam_file|
        with_attachment_tempfile(answer_key_pdf_attachment) do |answer_key_file|
          request_extract(exam_file:, answer_key_file:)
        end
      end
    end

    private

    attr_reader :base_url, :timeout

    def request_extract(exam_file:, answer_key_file:)
      uri = URI.parse("#{base_url}/extract")
      request = Net::HTTP::Post.new(uri)
      request.set_form(
        [
          ["prova", exam_file],
          ["gabarito", answer_key_file]
        ],
        "multipart/form-data"
      )

      response = Net::HTTP.start(
        uri.host,
        uri.port,
        open_timeout: timeout,
        read_timeout: timeout
      ) { |http| http.request(request) }

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Extractor returned #{response.code}: #{response.body}"
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise Error, "Invalid extractor JSON: #{e.message}"
    rescue StandardError => e
      raise Error, e.message
    end

    def with_attachment_tempfile(attachment)
      raise Error, "Missing attachment" unless attachment.attached?

      original_name = attachment.filename.to_s
      extension = File.extname(original_name)
      stem = File.basename(original_name, extension).gsub(/[^a-zA-Z0-9_-]/, "_")
      stem = "enem-import" if stem.blank?

      tempfile = Tempfile.new([stem, extension])
      tempfile.binmode
      tempfile.write(attachment.download)
      tempfile.rewind
      yield tempfile
    ensure
      tempfile&.close!
    end
  end
end
