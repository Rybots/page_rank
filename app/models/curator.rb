class Curator < ApplicationRecord
  has_many :csv_files, dependent: :destroy 
end
