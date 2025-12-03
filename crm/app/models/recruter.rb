class Recruter < ApplicationRecord
  belongs_to :agency
  has_many :deals
end
