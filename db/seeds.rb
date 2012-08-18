# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Meme.find_or_create_by_url('http://media.tumblr.com/tumblr_ljnio2uVgW1qzrid6.jpg')
Meme.find_or_create_by_url('http://media.tumblr.com/tumblr_ljniocImhv1qzrid6.jpg')
Meme.find_or_create_by_url('http://25.media.tumblr.com/tumblr_m8m84gDcYo1qe11kdo1_500.jpg')
Meme.find_or_create_by_url('http://memecrunch.com/meme/2XJE/rails-installation/image.png')

