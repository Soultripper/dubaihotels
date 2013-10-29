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
    { "london-greater-london-united-kingdom" => 'London',
      "paris-ile-de-france-france" => 'Paris',
      "rome-lazio-italy" => 'Rome',
      "barcelona-catalonia-spain" => 'Barcelona',
      "dublin-dublin-county-ireland" => 'Dublin',
      "madrid-community-of-madrid-spain" => 'Madrid',
      "amsterdam-noord-holland-netherlands" => 'Amsterdam',
      "prague-prague-region-czech-republic" => 'Prague',
      "moscow-russia" => 'Moscow',
      "vienna-vienna-state-austria" => 'Vienna',
      "saint-petersburg-leningrad-region-russia" => 'St. Petersburg',
      "venice-veneto-italy" => 'Venice',
      "warsaw-masovia-poland" => 'Warsaw',
      "dubrovnik-dubrovnik-neretva-county-croatia" => 'Dubrovnik',
      "benidorm-valencia-community-spain" => 'Benidorm',
      "berlin-berlin-federal-state-germany" => 'Berlin',
      "budapest-pest-hungary" => 'Budapest',
      "munich-bavaria-germany" => 'Munich',
      "milan-lombardy-italy" => 'Milan',
      "florence-tuscany-italy" => 'Florence',
      "lisbon-lisbon-region-portugal" => 'Lisbon'}
  end

  def middle_east_africa
    {"dubai-dubai-emirate-united-arab-emirates" =>'Dubai',
      "jerusalem-jerusalem-district-israel" => 'Jerusalem',
      "tel-aviv-tel-aviv-district-israel" => 'Tel Aviv',
      "abu-dhabi-abu-dhabi-emirate-united-arab-emirates" => 'Abu Dhabi',
      "beirut-mount-lebanon-lebanon" => 'Beirut',
      "amman-amman-governorate-jordan" => 'Amman',
      "doha-qatar" => 'Doha',
      "manama-capital-governorate-bahrain" => 'Manama',
      "riyadh-riyadh-province-saudi-arabia" => 'Riyadh',
      '' => 'Damascus',
      "muscat-muscat-oman" => 'Muscat',
      "marrakech-marrakech-tensift-haouz-morocco" => 'Marrakech',
      "cape-town-western-cape-south-africa" => 'Cape Town',
      "cairo-cairo-governate-egypt" => 'Cairo',
      "johannesburg-gauteng-south-africa" => 'Johannesburg',
      "sharm-el-sheikh-south-sinai-egypt" => 'Sharm El Sheikh',
      "fes-fes-boulmane-morocco" => 'Fez',
      "luxor-luxor-egypt" => 'Luxor',
      "hurghada-red-sea-egypt" => 'Hurghada',
      "nairobi-kenya" => 'Nairobi'}
  end

  def asia_pacific
    {"bangkok-bangkok-province-thailand" => 'Bangkok',
      "bali-crete-greece" => 'Bali',
      "beijing-beijing-china" => 'Beijing',
      "shanghai-shanghai-china" => 'Shanghai',
      "phuket-town-phuket-thailand" => 'Phuket',
      "kuala-lumpur-kuala-lumpur-federal-territory-malaysia"=> 'Kuala Lumpur',
      "new-delhi-delhi-india" => 'New Delhi',
      "tokyo-tokyo-prefecture-japan" => 'Tokyo',
      "singapore-singapore" => 'Singapore',
      "hanoi-ha-noi-municipality-vietnam" => 'Hanoi',
      "ho-chi-minh-city-ho-chi-minh-municipality-vietnam" => 'Ho Chi Minh City',
      "siem-reap-siem-reap-province-cambodia" => 'Siem Reap',
      "chiang-mai-chiang-mai-province-thailand" => 'Chiang Mai',
      "seoul-seoul-special-city-south-korea" => 'Seoul',
      "guangzhou-guangdong-china" => 'Guangzhou',
      '' => 'Koh Samui',
      "hong-kong-hong-kong" => 'Hong Kong',
      "pattaya-central-chon-buri-thailand" => 'Pattaya',
      "sydney-new-south-wales-australia" => 'Sydney',
      "melbourne-victoria-australia" => 'Melbourne'}
  end
end
