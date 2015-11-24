class Vehicle < ActiveRecord::Base
	self.table_name = "vehicle"
	belongs_to :supplier

	mount_uploader :image, ImageUploader
	validate :image_size

	private

def image_size
  if image.size > 5.megabytes
    errors.add(:image, "should be less than 5MB")
  end
end
end