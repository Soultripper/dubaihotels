class RoomSearch
  
  attr_reader :start_date, :end_date, :no_of_rooms, :no_of_adults, :min_stars, :max_stars

  attr_accessor :children, :min_stars, :max_stars

  def initialize(start_date, end_date, args={})
    @start_date, @end_date = start_date, end_date
    @no_of_rooms  = args[:no_of_rooms]  || 1
    @no_of_adults = args[:no_of_adults] || 2
    @min_stars    = args[:min_stars]    || 1
    @max_stars    = args[:max_stars]    || 5
  end


  def all_stars?
    @min_stars == 1 and @max_stars == 5
  end

  def children?
    children and !children.empty?
  end

  def add_child_of(age)
    @children ||= []
    @children << age
  end

  def to_hash
    Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
  end

  def to_s
    s_children = children? ?  children.join('_') : "no_children"
    "#{start_date.to_date.to_s}_#{end_date.to_date.to_s}_rooms#{no_of_rooms}_adults#{no_of_adults}_#{s_children}_min_stars#{min_stars}_max_stars#{max_stars}"
  end

  def total_nights
    (end_date - start_date).to_i
  end
   
end