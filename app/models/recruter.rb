class Recruter < ApplicationRecord
  belongs_to :agency
  has_many :deals

  def to_s
    name
  end
end
