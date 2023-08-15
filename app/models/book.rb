@currencies =
  %w[AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD BND BOB BRL BSD BTN BWP BYN BZD CAD CDF CHF
       CLP CNY COP CRC CUC CUP CVE CZK DJF DKK DOP DZD EGP ERN ETB EUR FJD FKP GBP GEL GGP GHS GIP GMD GNF GTQ GYD HKD
       HNL HRK HTG HUF IDR ILS IMP INR IQD IRR ISK JEP JMD JOD JPY KES KGS KHR KMF KPW KRW KWD KYD KZT LAK LBP LKR LRD
       LSL LYD MAD MDL MGA MKD MMK MNT MOP MRU MUR MVR MWK MXN MYR MZN NAD NGN NIO NOK NPR NZD OMR PAB PEN PGK PHP PKR
       PLN PYG QAR RON RSD RUB RWF SAR SBD SCR SDG SEK SGD SHP SLL SOS SPL SRD STN SVC SYP SZL THB TJS TMT TND TOP TRY
       TTD TVD TWD TZS UAH UGX USD UYU UZS VEF VES VND]

class Book < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :release_date, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, inclusion: @currencies, presence: true

  before_validation :set_default_rating

  def update_average_rating
    total_reviews = reviews.count
    return if total_reviews.zero?

    total_rating = reviews.sum(:rating)
    self.rating = total_rating.to_f / total_reviews
    save
  end



  private

  def set_default_rating
    self.rating ||= 0
  end
end
