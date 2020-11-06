# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Demo Org
org = Organization.find_or_create_by(name: 'Demo Organization')

# Demo User
demo_user = User.find_by(username: 'demo')

unless demo_user
  demo_user = User.new(
    name: 'Demo',
    username: 'demo',
    password_digest: BCrypt::Password.create('demo'),
    organization: org
  )

  demo_user.save(validate: false)
  demo_user.add_role(:admin)
end

# Data sources (Loaders)
sources = JSON.parse(YAML.load(File.read('load_config/config.yaml')).to_json)

sources['buckets']&.each do |ds|
  res = Source.find_or_create_by(name: ds)
  puts "Source: #{ds}"
end

sources['local_dirs']&.each do |ds|
  res = Source.find_or_create_by(name: ds)
  puts "Source: #{ds}"
end

# Profiles
profiles = YAML.load(File.read('db/sample_profiles.yml'))

profiles.each do |p|
  res = Profile.find_or_create_by(name: p['name'])
  # res.tags = p['tags'].map { |t| t.downcase }
  res.update(p)
end

# Import Controls from Control Packs
PackJob.perform_later
