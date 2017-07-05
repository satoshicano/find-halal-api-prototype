# == Schema Information
#
# Table name: pictures
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :string
#

class Picture < ApplicationRecord
  mount_uploader :image, ImageUploader

  def check_halal
    Vision.new(image.path).check
  end
end
