# == Schema Information
#
# Table name: pictures
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Picture < ApplicationRecord
  mount_uploader :image, ImageUploader

  def check_halal
    desc = Vision.new(image.path).request
    { status: fetch_halal_status(desc), descriptions: desc }
  end

  # Vision.translate_annotate(halal_word)
  def fetch_halal_status(desc)
    halal_words = Word.pluck(:name)
    halal_words.each do |halal_word|
      desc.each do |d|
        # return false if d.downcase.include?(halal_word)
        if d.downcase.include?(halal_word)
          Vision.translate_annotate(halal_word)
          return false
        end
      end
    end
    true
  end
end
