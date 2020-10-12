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
end

# Data sources (Loaders)
sources = YAML.load(File.read('db/sample_data_sources.yml'))

sources.each do |ds|
  res = Source.find_or_create_by(name: ds['name'])
  res.update(ds)
end

# Profiles
profiles = YAML.load(File.read('db/sample_profiles.yml'))

profiles.each do |p|
  res = Profile.find_or_create_by(name: p['name'])
  # res.tags = p['tags'].map { |t| t.downcase }
  res.update(p)
end

# Import Controls from Control Packs
Dir['controls/**/config.yaml'].each do |file|
  control_pack = JSON.parse(YAML.load(File.read(file)).to_json, object_class: OpenStruct)

  control_pack&.controls&.each do |control|
    puts "Control: #{control_pack.id} - #{control.id}"
    res = Control.find_or_create_by(control_pack: control_pack.id, control_id: control.id)
    res.tags.destroy_all
    control&.tags&.map { |t| res.tags << Tag.find_or_create_by(name: t) }
    res.update(
      guid: Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, control_pack.id + control.id),
      control_pack: control_pack.id,
      control_id: control.id,
      title: control.title,
      description: control.description,
      impact: control.impact,
      platform: control.platform,
      validation: control.validation,
      remediation: control.remediation,
      refs: control.refs
    )
  end
end
