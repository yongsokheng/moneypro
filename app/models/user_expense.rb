class UserExpense < ActiveRecord::Base
  paginates_per Settings.pagination.per_page
  belongs_to :expense_category
  belongs_to :payment_method
  belongs_to :user

  validates :amount, presence: true, numericality: {greater_than: 0}
  validates :date, presence: true

  delegate :name, to: :expense_category, prefix: true, allow_nil: true
  delegate :name, to: :payment_method, prefix: true, allow_nil: true

  scope :daily_expense, ->payment_method_id, user_id{
    if Settings.payment_methods.all == payment_method_id
      where("date = ? and user_id = ?", Date.today, user_id)
    else
      where("date = ? and payment_method_id = ? and user_id = ?",
        Date.today, payment_method_id, user_id)
    end
  }

  scope :monthly_expense, ->payment_method_id, user_id{
    if Settings.payment_methods.all == payment_method_id
      where("user_id = ? and date >= ? and date <= ?",
        user_id, Date.today.at_beginning_of_month, Date.today.end_of_month)
    else
      where("user_id = ? and date >= ? and date <= ? and payment_method_id = ?",
        user_id, Date.today.at_beginning_of_month, Date.today.end_of_month, payment_method_id)
    end
  }

  scope :yearly_expense, ->payment_method_id, user_id{
    if Settings.payment_methods.all == payment_method_id
      where("user_id = ? and date >= ? and date <= ?",
        user_id, Date.today.at_beginning_of_year, Date.today.end_of_year)
    else
      where("user_id = ? and date >= ? and date <= ? and payment_method_id = ?",
        user_id, Date.today.at_beginning_of_year, Date.today.end_of_year, payment_method_id)
    end
  }

  scope :total_expense_before, ->payment_method_id, user_id, date{
    if Settings.payment_methods.all == payment_method_id
      where("date < ? and user_id = ?", date, user_id)
    else
      where("date < ? and payment_method_id = ? and user_id = ?",
        date, payment_method_id, user_id)
    end
  }

  scope :total_expense, ->payment_method_id, user_id{
    if payment_method_id
      where("user_id = ?", user_id)
    else
      where("payment_method_id = ? and user_id = ?",
        payment_method_id, user_id)
    end
  }

end
