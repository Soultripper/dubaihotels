class SearchDetails

  attr_reader :search_criteria, :location

  def initialize(search_criteria, location)
    @search_criteria = search_criteria
    @location = location
  end

  def valid?
    search_criteria.valid? and location
  end


end
