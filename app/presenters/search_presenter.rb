class SearchPresenter < BasePresenter
  extend Forwardable

  presents :search
  def_delegators :search, :start_date, :end_date

  def check_in
    pretty_print start_date
  end

  def check_out
    pretty_print end_date
  end

  def pretty_print(date)
    date.strftime('%A, %b, %Y')
  end
end