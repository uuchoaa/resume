class Deal < ApplicationRecord
  belongs_to :agency
  belongs_to :recruter

  enum :stage, {
    open: 0,
    screening: 1,
    company_screening: 2,
    tech_assessment: 3,
    cultural_fit: 4,
    offer: 5,
    closed: -1
  }

  validates :description, presence: true
  validates :stage, presence: true, inclusion: { in: stages.keys }
  validates :agency, presence: true
  validates :recruter, presence: true
end
