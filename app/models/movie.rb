class Movie < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :title, :released_on, :duration, presence: true
  validates :description, length: { minimum: 25 }
  validates :total_gross, numericality: { greater_than_or_equal_to: 0 }
  validates :image_file_name, format: {
    with: /\w+\.(jpg|png)\z/i,
    message: 'Must be a JPG or PNG image'
  }
  RATINGS = %w[G PG PG-13 R NC-17].freeze
  validates :rating, inclusion: { in: RATINGS }

  def flop?
    if reviews.count > 10 && reviews.average(:stars) >= 0.4
      false
    else
      total_gross.blank? || total_gross < 225_000_000
    end
  end

  def self.released
    where('released_on < ?', Time.now).order(released_on: :desc)
  end

  def avg_stars
    reviews.average(:stars) || 0.0
  end

  def avg_stars_as_percent
    (self.avg_stars / 5.0) * 100
  end
end
