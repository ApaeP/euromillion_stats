class Year < ApplicationRecord
  has_many :tirages, dependent: :destroy
end
