# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  name       :string
#  english    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Word < ApplicationRecord
end
