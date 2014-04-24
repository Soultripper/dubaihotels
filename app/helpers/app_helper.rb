module AppHelper

  def city_link(city)
    content_tag :li do
      link_to city[1], city[0], target: '_self'
    end
  end

  def north_america
    {"new-york" => 'New York',
    "las-vegas" => 'Las Vegas',
    "san-francisco" => 'San Francisco',
    "los-angeles" => 'Los Angeles',
    "chicago" => 'Chicago',
    "san-diego" => 'San Diego',
    "washington" => 'Washington',
    "orlando" => 'Orlando',
    "toronto" => 'Toronto',
    "montreal" => 'Montreal',
    "houston" => 'Houston',
    "new-orleans" => 'New Orleans',
    "seattle" => 'Seattle',
    "vancouver" => 'Vancouver',
    "cancun" => 'Cancun',
    "san-antonio" => 'San Antonio',
    "miami-florida" => 'Miami',
    "mexico" => 'Mexico City',
    "playa-del-carmen" => 'Playa del Carmen',
    "boston" => 'Boston'}
  end

  def south_america
    {"buenos-aires" => 'Buenos Aires',
    "rio-de-janeiro" => 'Rio de Janeiro',
    "lima" => 'Lima',
    "cusco" => 'Cusco',
    "santiago" => 'Santiago',
    "bogota" => 'Bogota',
    "sao-paulo" => 'Sao Paulo',
    "quito" => 'Quito',
    "cartagena" => 'Cartagena',
    "san-carlos-de-bariloche" => 'Bariloche',
    "buzios" => 'Buzios',
    "salvador" => 'Salvador da Bahia',
    "arequipa" => 'Arequipa',
    "florianopolis" => 'Florianopolis',
    "puerto-iguazu" => 'Puerto Iguazu',
    "la-paz" => 'La Paz',
    "paraty" => 'Paraty',
    "medellin" => 'Medellin',
    "mendoza" => 'Mendoza',
    "porto-seguro" => 'Porto Seguro'}
  end

  def europe
    { "london" => 'London',
      "paris" => 'Paris',
      "rome" => 'Rome',
      "barcelona" => 'Barcelona',
      "dublin" => 'Dublin',
      "madrid" => 'Madrid',
      "amsterdam" => 'Amsterdam',
      "prague" => 'Prague',
      "moscow" => 'Moscow',
      "vienna" => 'Vienna',
      "saint-petersburg" => 'St. Petersburg',
      "venice" => 'Venice',
      "warsaw" => 'Warsaw',
      "dubrovnik" => 'Dubrovnik',
      "benidorm" => 'Benidorm',
      "berlin" => 'Berlin',
      "budapest" => 'Budapest',
      "munich" => 'Munich',
      "milan" => 'Milan',
      "florence" => 'Florence',
      "lisbon" => 'Lisbon'}
  end

  def middle_east_africa
    {"dubai" =>'Dubai',
      "jerusalem" => 'Jerusalem',
      "tel-aviv" => 'Tel Aviv',
      "abu-dhabi" => 'Abu Dhabi',
      "beirut" => 'Beirut',
      "amman" => 'Amman',
      "doha" => 'Doha',
      "manama" => 'Manama',
      "riyadh" => 'Riyadh',
      '' => 'Damascus',
      "musca" => 'Muscat',
      "marrakech" => 'Marrakech',
      "cape-town" => 'Cape Town',
      "cairo" => 'Cairo',
      "johannesburg" => 'Johannesburg',
      "sharm-el-sheikh" => 'Sharm El Sheikh',
      "fes" => 'Fez',
      "luxor" => 'Luxor',
      "hurghada" => 'Hurghada',
      "nairobi" => 'Nairobi'}
  end

  def asia_pacific
    {"bangkok" => 'Bangkok',
      "bali" => 'Bali',
      "beijing" => 'Beijing',
      "shanghai" => 'Shanghai',
      "phuket-town" => 'Phuket',
      "kuala-lumpur"=> 'Kuala Lumpur',
      "new-delhi" => 'New Delhi',
      "tokyo" => 'Tokyo',
      "singapore" => 'Singapore',
      "hanoi" => 'Hanoi',
      "ho-chi-minh-city" => 'Ho Chi Minh City',
      "siem-reap" => 'Siem Reap',
      "chiang-mai" => 'Chiang Mai',
      "seoul" => 'Seoul',
      "guangzhou" => 'Guangzhou',
      '' => 'Koh Samui',
      "hong-kong" => 'Hong Kong',
      "pattaya" => 'Pattaya',
      "sydney" => 'Sydney',
      "melbourne" => 'Melbourne'}
  end

  def display_star_rating(index, hotel_star_rating)
    hotel_star_rating = hotel_star_rating.to_f
    if hotel_star_rating > index and hotel_star_rating < index+1
      content_tag(:i, nil, class: "fa fa-star-half-empty") 
    elsif hotel_star_rating > index
      content_tag(:i, nil, class: "fa fa-star") 
    else
      content_tag(:i, nil, class: "fa fa-star-o") 
    end
  end

end
