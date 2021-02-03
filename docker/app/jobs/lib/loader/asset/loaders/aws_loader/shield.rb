# frozen_string_literal: true

#
# Load Shield assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Shield < GraphDbLoader
  def subscription
    node = 'AWS_SHIELD_SUBSCRIPTION'

    q = []

    # subscription node
    q.push(_upsert({ node: node, id: @name }))
  end

  def contact_list
    node = 'AWS_SHIELD_CONTACT_LIST'

    q = []

    # contact_list node
    q.push(_upsert({ node: node, id: @name }))

    # contacts
    @data&.contacts&.each_with_index do |contact, i|
      contact_id = "#{@name}/contact_#{i}"

      opts = {
        node: 'AWS_SHIELD_CONTACT_LIST_CONTACT',
        id: contact_id,
        data: {
          email: contact.email_address,
          phone: contact.phone_number
        },
        headless: true
      }

      q.push(_upsert(opts))

      # contact_list -> contact
      opts = {
        from_node: 'AWS_SHIELD_CONTACT_LIST',
        from_name: @name,
        to_node: 'AWS_SHIELD_CONTACT_LIST_CONTACT',
        to_name: contact_id,
        relationship: 'HAS_CONTACT'
      }

      q.push(_link(opts))
    end

    q
  end

  def protection
    node = 'AWS_SHIELD_PROTECTION'
    q = []

    # protection node
    q.push(_upsert({ node: node, id: @name }))
  end
end
