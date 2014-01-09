require 'pusher'

if Rails.env=='development'
  Pusher.url = "http://e49cfdb8b8f62652d358:20dbcf2dcd4b6b382988@api-eu.pusher.com/apps/59660"
else
  Pusher.url = "http://1163c38d8c21940bd111:801d43e5a69c48a712c9@api-eu.pusher.com/apps/59659"
end
Pusher.logger = Rails.logger