class Agency < ApplicationRecord
  has_many :deals

  def to_s
    name
  end
end
