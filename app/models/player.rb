class Player < ActiveRecord::Base
  def self.convert_name_from_url_name(url_name)
    Player.where(url_name: url_name).take.name
  end
end
