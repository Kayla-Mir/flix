class Movie < ApplicationRecord
  before_save :set_slug

  has_many :reviews, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :fans, through: :favorites, source: :user
  has_many :characterizations, dependent: :destroy
  has_many :genres, through: :characterizations

  validates :title, presence: true, uniqueness: true
  validates :released_on, :duration, presence: true
  validates :description, length: {minimum: 25}
  validates :total_gross, numericality: {greater_than_or_equal_to: 0}
  validates :image_file_name, format: {
    with: /\w+\.(jpg|png)\z/i,
    message: "Must be a JPG or PNG image"
  }
  RATINGS = %w[G PG PG-13 R NC-17].freeze
  validates :rating, inclusion: {in: RATINGS}

  scope :released, -> { where("released_on < ?", Time.now).order("released_on DESC") }
  scope :upcoming, -> { where("released_on > ?", Time.now).order("released_on ASC") }
  scope :recent, ->(max = 5) { released.limit(max) }
  scope :hits, -> { released.where("total_gross >= 300000000").order(total_gross: :desc) }
  scope :flops, -> { released.where("total_gross < 225000000").order(total_gross: :asc) }
  scope :grossed_less_than, ->(amount) { released.where("total_gross < ?", amount) }
  scope :grossed_greater_than, ->(amount) { released.where("total_gross > ?", amount) }

  def flop?
    if reviews.count > 10 && reviews.average(:stars) >= 0.4
      false
    else
      total_gross.blank? || total_gross < 225_000_000
    end
  end

  def avg_stars
    reviews.average(:stars) || 0.0
  end

  def avg_stars_as_percent
    (avg_stars / 5.0) * 100
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = title.parameterize
  end
end
