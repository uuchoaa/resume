class Agency < ApplicationRecord
  has_many :deals

  validates :name, presence: true

  def to_s
    name
  end
end
