class RoomSearch
  
  attr_reader :start_date, :end_date, :no_of_rooms, :no_of_adults

  attr_accessor :children

  def initialize(start_date, end_date, no_of_rooms=1, no_of_adults=2)
    @start_date, @end_date, @no_of_rooms, @no_of_adults = start_date, end_date, no_of_rooms, no_of_adults
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

  def children_to_s
    
  end

  def to_s
    s_children = children? ?  children.join('_') : "no_children"
    "#{start_date.to_date.to_s}_#{end_date.to_date.to_s}_rooms#{no_of_rooms}_adults#{no_of_adults}_#{s_children}"
  end
   
end