class Micropost < ApplicationRecord
  belongs_to :user
  scope :order_desc, -> {order created_at: :desc}
  scope :feed, ->(id){where user_id: id}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.validates.max_length_micropost}
  validate  :picture_size

  private

  # Validates the size of an uploaded picture.
  def picture_size
    return unless picture.size > Settings.picture_size.megabytes
    errors.add(:picture, t(".size"))
  end
end
