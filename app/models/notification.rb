class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :targetable, polymorphic: true

  scope :is_not_read, -> {where is_read: false}
end