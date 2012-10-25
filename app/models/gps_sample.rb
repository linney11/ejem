class GpsSample < ActiveRecord::Base
  # Set attributes as accessible for mass-assignment
  attr_accessible :latitude, :longitude, :time, :user_id, :file
end
