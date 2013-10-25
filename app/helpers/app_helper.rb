module AppHelper

  def city_link(city)
    content_tag :li do
      link_to city[1], city[0]
    end
  end

  def north_america
    {"new-york-new-york-state-usa" => 'New York',
    "las-vegas-nevada-usa" => 'Las Vegas',
    "san-francisco-california-usa" => 'San Francisco',
    "los-angeles-california-usa" => 'Los Angeles',
    "chicago-illinois-usa" => 'Chicago',
    "san-diego-california-usa" => 'San Diego',
    "washington-district-of-columbia-usa" => 'Washington',
    "orlando-florida-usa" => 'Orlando',
    "toronto-ontario-canada" => 'Toronto',
    "montreal-quebec-canada" => 'Montreal',
    "houston-texas-usa" => 'Houston',
    "new-orleans-louisiana-usa" => 'New Orleans',
    "seattle-washington-state-usa" => 'Seattle',
    "vancouver-british-columbia-canada" => 'Vancouver',
    "cancun-quintana-roo-mexico" => 'Cancun',
    "san-antonio-texas-usa" => 'San Antonio',
    "miami-florida-usa" => 'Miami',
    "mexico-city-state-of-mexico-mexico" => 'Mexico City',
    "playa-del-carmen-quintana-roo-mexico" => 'Playa del Carmen',
    "boston-massachusetts-usa" => 'Boston'}
  end

  def south_america
    {"buenos-aires-argentina" => 'Buenos Aires',
    "rio-de-janeiro-rio-de-janeiro-state-brazil" => 'Rio de Janeiro',
    "lima-peru" => 'Lima',
    "cusco-cusco-peru" => 'Cusco',
    "santiago-chile" => 'Santiago',
    "bogota-colombia" => 'Bogota',
    "sao-paulo-sao-paulo-state-brazil" => 'Sao Paulo',
    "quito-ecuador" => 'Quito',
    "cartagena-de-indias-bolivar-colombia" => 'Cartagena',
    "san-carlos-de-bariloche-rio-negro-argentina" => 'Bariloche',
    "buzios-rio-de-janeiro-state-brazil" => 'Buzios',
    "salvador-bahia-brazil" => 'Salvador da Bahia',
    "arequipa-arequipa-province-peru" => 'Arequipa',
    "florianopolis-santa-catarina-brazil" => 'Florianopolis',
    "puerto-iguazu-misiones-argentina" => 'Puerto Iguazu',
    "la-paz-bolivia" => 'La Paz',
    "paraty-rio-de-janeiro-state-brazil" => 'Paraty',
    "medellin-antioquia-colombia" => 'Medellin',
    "mendoza-mendoza-argentina" => 'Mendoza',
    "porto-seguro-bahia-brazil" => 'Porto Seguro'}
  end

  def europe
    [
      'London',
      'Paris',
      'Rome',
      'Barcelona',
      'Dublin',
      'Madrid',
      'Amsterdam',
      'Prague',
      'Moscow',
      'Vienna',
      'St. Petersburg',
      'Venice',
      'Warsaw',
      'Dubrovnik',
      'Benidorm',
      'Berlin',
      'Budapest',
      'Munich',
      'Milan',
      'Florence',
      'Lisbon'
    ]
  end

  def middle_east_africa
    [
      'Dubai',
      'Jerusalem',
      'Tel Aviv',
      'Abu Dhabi',
      'Beirut',
      'Anman',
      'Petra',
      'Doha',
      'Manama',
      'Riyadh',
      'Damascus',
      'Muscat',
      'Marrakech',
      'Cape Town',
      'Cairo',
      'Johannesburg',
      'Sham El Sheikh',
      'Fez',
      'Luxor',
      'Hurghada',
      'Nairobi'
    ]
  end

  def asia_pacific
    [
      'Bangkok',
      'Bali',
      'Beijing',
      'Shanghai',
      'Phuket',
      'Kuala Lumpur',
      'New Delhi',
      'Tokyo',
      'Singapore',
      'Hanoi',
      'Ho Chi Minh City',
      'Siem Reap',
      'Chiang Mai',
      'Seoul',
      'Guanzhou',
      'Koh Samui',
      'Hong Kong',
      'Pattaya',
      'Sydney',
      'Melbourne'
    ]
  end
end
