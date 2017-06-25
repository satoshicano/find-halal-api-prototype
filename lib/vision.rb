require 'rmagick'

class Vision
  attr_accessor :endpoint, :file_path

  def initialize(file_path)
    key = Rails.application.secrets[:api_key]
    @endpoint = "https://vision.googleapis.com/v1/images:annotate?key=#{key}"
    @file_path = file_path
  end

  def check
    http_client = HTTPClient.new
    content = Base64.strict_encode64(File.new(file_path, 'rb').read)
    response = http_client.post_content(endpoint, request_json(content), 'Content-Type' => 'application/json')
    no_halal_foods = fetch_no_halal_food(response)
    return { status: '0' } if no_halal_foods.empty?
    annotate_no_halal_food(no_halal_foods)
    { status: '1' }
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

  def fetch_no_halal_food(response) # rubocop:disable Metrics/MethodLength
    result = JSON.parse(response)['responses'].first
    no_halal_foods = []
    no_halal_words = Word.pluck(:name, :english).each
    result['textAnnotations'].map do |text|
      no_halal_words.each do |word|
        if text['description'].include?(word[0])
          no_halal_foods.push(text)
          no_halal_foods.last[:word] = word[1]
          break
        end
      end
    end
    no_halal_foods.shift
    no_halal_foods
  end

  def annotate_no_halal_food(no_halal_foods)
    image = Magick::ImageList.new(@file_path)

    no_halal_foods.each do |foods|
      draw_annotate(image, calc_length(foods['boundingPoly']['vertices']), foods[:word])
    end

    image.write(@file_path)
  end

  def draw_annotate(image, vertices, word)
    draw = Magick::Draw.new
    draw.fill('#FFFFFF')
    draw.rectangle(vertices[:x1], vertices[:y1], vertices[:x2], vertices[:y2])
    draw.draw(image)

    draw = Magick::Draw.new
    font = 'DejaVu-Sans'
    draw.annotate(image, vertices[:width], vertices[:height], vertices[:x3], vertices[:y3], word) do
      self.font = font
      self.pointsize = 64
    end
  end

  def calc_length(vertices)
    {
      x1: vertices[0]['x'],
      y1: vertices[0]['y'],
      x2: vertices[2]['x'],
      y2: vertices[2]['y'],
      x3: vertices[3]['x'],
      y3: vertices[3]['y'],
      height: vertices[3]['y'] - vertices[0]['y'],
      width: vertices[1]['x'] - vertices[0]['x']
    }
  end
end
