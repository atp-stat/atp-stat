class Ranking < ActiveRecord::Base
  belongs_to :player, foreign_key: :name, primary_key: :name
end
