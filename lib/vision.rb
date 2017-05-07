require 'rmagick'

class Vision
  attr_accessor :endpoint, :file_path

  def initialize(file_path)
    key = FindHalalApiPrototype::Application.secrets[:api_key]
    @endpoint = "https://vision.googleapis.com/v1/images:annotate?key=#{key}"
    @file_path = file_path
  end

  def request
    http_client = HTTPClient.new
    content = Base64.strict_encode64(File.new(file_path, 'rb').read)
    response = http_client.post_content(
      endpoint, request_json(content), 'Content-Type' => 'application/json'
    )
    fetch_descriptions(response)
  end

  def request_json(content)
    {
      requests: [{
        image: { content: content },
        features: [{
          type: 'TEXT_DETECTION',
          maxResults: 100
        }]
      }]
    }.to_json
  end

  def fetch_descriptions(response)
    result = JSON.parse(response)['responses'].first
    result['textAnnotations'].map { |text| text['description'] }
  end

  def translate_annotate(word)
    image = Magick::ImageList.new(@file_path)
    draw = Magick::Draw.new
    draw.annotate(image, 100, 200, 300, 400, word)
    image.write(@file_path)
  end
end
