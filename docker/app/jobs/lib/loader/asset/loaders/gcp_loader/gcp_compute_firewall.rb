class GCP_COMPUTE_FIREWALL < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # grab/delete associated networks
    network = asset.dig('resource', 'data').delete('network')
    direction = asset.dig('resource', 'data', 'direction')

    # Capture all aspects of this firewall resource
    source_ranges = []
    if asset.dig('resource','data', 'sourceRanges')
      source_ranges = asset.dig('resource','data').delete('sourceRanges')
    end
    destination_ranges = []
    if asset.dig('resource','data', 'destionationRanges')
      destination_ranges = asset.dig('resource','data').delete('destinationRanges')
    end
    source_tags = []
    if asset.dig('resource','data', 'sourceTags')
      source_tags = asset.dig('resource','data').delete('sourceTags')
    end
    target_tags = []
    if asset.dig('resource','data', 'targetTags')
      target_tags = asset.dig('resource','data').delete('targetTags')
    end
    source_service_accounts = []
    if asset.dig('resource','data', 'sourceServiceAccounts')
      source_service_accounts = asset.dig('resource','data').delete('sourceServiceAccounts')
    end
    target_service_accounts = []
    if asset.dig('resource','data', 'targetServiceAccounts')
      target_service_accounts = asset.dig('resource','data').delete('targetServiceAccounts')
    end
    allowed = []
    if asset.dig('resource','data', 'allowed')
      allowed = asset.dig('resource','data').delete('allowed')
    end
    denied = []
    if asset.dig('resource','data', 'denied')
      allowed = asset.dig('resource','data').delete('denied')
    end

    # cleanup
    if asset.dig('resource','data', 'selfLink')
      asset.dig('resource', 'data').delete('selfLink')
    end
    asset.delete('ancestors')

    # prep for updating or creating
    previous_properties_as_null = fetch_current_properties_as_null(@asset_label, @asset_name)
    properties = prepare_properties(asset)
    query = """
      MERGE (a:#{@asset_label} { name: \"#{@asset_name}\" })
      ON CREATE SET a.asset_type = \"#{@asset_type}\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\", #{properties}
      ON MATCH SET #{previous_properties_as_null} a.asset_type = \"#{@asset_type}\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\", #{properties}
    """
    graphquery(query)

    # Relationships to networks
    compute_network_name = compute_url_to_compute_name(network)
    query = """
      MATCH (s:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      MERGE (a)-[:HAS_FIREWALL]->(s)
    """
    graphquery(query)

    # Source Ranges
    unless source_ranges.empty?
      source_ranges.each do |range_name|
        query = """
          MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_COMPUTE_FIREWALLIPRANGE { name: \"#{range_name}\" })
          ON CREATE SET a.asset_type = \"compute.googleapis.com/FirewallIpRange\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          ON MATCH SET  a.asset_type = \"compute.googleapis.com/FirewallIpRange\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          MERGE (f)-[:HAS_SOURCEIPRANGE]->(a)
        """
        graphquery(query)
      end
    end
    # Destionation Ranges
    unless destination_ranges.empty?
      destination_ranges.each do |range_name|
        query = """
          MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_COMPUTE_FIREWALLIPRANGE { name: \"#{range_name}\" })
          ON CREATE SET a.asset_type = \"compute.googleapis.com/FirewallIpRange\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          ON MATCH SET  a.asset_type = \"compute.googleapis.com/FirewallIpRange\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          MERGE (f)-[:HAS_DESTINATIONIPRANGE]->(a)
        """
        graphquery(query)
      end
    end

    # Source Tags
    unless source_tags.empty?
      source_tags.each do |tag_name|
        query = """
          MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_COMPUTE_NETWORKTAG { name: \"#{tag_name}\" })
          ON CREATE SET a.asset_type = \"compute.googleapis.com/NetworkTag\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          ON MATCH SET  a.asset_type = \"compute.googleapis.com/NetworkTag\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          MERGE (f)-[:HAS_SOURCENETWORKTAG]->(a)
        """
        graphquery(query)
      end
    end
    # Target Tags
    unless target_tags.empty?
      target_tags.each do |tag_name|
        query = """
          MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_COMPUTE_NETWORKTAG { name: \"#{tag_name}\" })
          ON CREATE SET a.asset_type = \"compute.googleapis.com/NetworkTag\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          ON MATCH SET  a.asset_type = \"compute.googleapis.com/NetworkTag\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          MERGE (f)-[:HAS_TARGETNETWORKTAG]->(a)
        """
        graphquery(query)
      end
    end

    # Source Service Accounts
    unless source_service_accounts.empty?
      source_service_accounts.each do |sa_name|
        query = """
          MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_IDENTITY { name: \"serviceAccount:#{sa_name}\" })
          ON CREATE SET a.asset_type = \"iam.googleapis.com/ServiceAccount\",
                        a.member_name = \"#{sa_name}\",
                        a.member_type = \"serviceAccount\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          ON MATCH SET  a.asset_type = \"iam.googleapis.com/ServiceAccount\",
                        a.member_name = \"#{sa_name}\",
                        a.member_type = \"serviceAccount\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          MERGE (f)-[:HAS_SOURCESERVICEACCOUNT]->(a)
        """
        graphquery(query)
      end
    end
    # Target Service Accounts
    unless target_service_accounts.empty?
      target_service_accounts.each do |sa_name|
        query = """
          MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_IDENTITY { name: \"serviceAccount:#{sa_name}\" })
          ON CREATE SET a.asset_type = \"iam.googleapis.com/ServiceAccount\",
                        a.member_name = \"#{sa_name}\",
                        a.member_type = \"serviceAccount\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          ON MATCH SET  a.asset_type = \"iam.googleapis.com/ServiceAccount\",
                        a.member_name = \"#{sa_name}\",
                        a.member_type = \"serviceAccount\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\"
          MERGE (f)-[:HAS_TARGETSERVICEACCOUNT]->(a)
        """
        graphquery(query)
      end
    end

    # If direction is ingress and no targets, the target network is this VPC
    if direction == 'INGRESS' && destination_ranges.empty? && target_service_accounts.empty? && target_tags.empty?
      query = """
        MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        ON MATCH SET  a.asset_type = \"compute.googleapis.com/Network\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        MERGE (f)-[:HAS_TARGETNETWORK]->(a)
      """
      graphquery(query)

    end

    # If direction is egress and no sources, the source network is this VPC
    if direction == 'EGRESS' && source_ranges.empty? && source_service_accounts.empty? && source_tags.empty?
      query = """
        MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        ON MATCH SET  a.asset_type = \"compute.googleapis.com/Network\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        MERGE (f)-[:HAS_SOURCENETWORK]->(a)
      """
      graphquery(query)
    end

    # Allowed "rules"
    allowed.each do |allow_proto|
      ipprotocol = allow_proto.dig('IPProtocol') || "all"
      if allow_proto.dig('ports')
        # Create just the protocol rel for each port/port-range
        ports = allow_proto.dig('ports')
        ports.each do |allow_port|
          if allow_port =~ /\d+\-\d+/
            from_port = allow_port.split('-')[0].to_i
            to_port = allow_port.split('-')[1].to_i
          else
            from_port = allow_port.to_i
            to_port = allow_port.to_i
          end

          firewall_rule_relationship(@asset_label, @asset_name, "GCP_COMPUTE_NETWORKPROTOCOL", ipprotocol, "compute.googleapis.com/NetworkProtocol", "HAS_FIREWALLRULE", "allow", from_port, to_port)

        end
      else
        # Create just the protocol rel with default ports
        firewall_rule_relationship(@asset_label, @asset_name, "GCP_COMPUTE_NETWORKPROTOCOL", ipprotocol, "compute.googleapis.com/NetworkProtocol", "HAS_FIREWALLRULE", "allow", 0, 65535)
      end
    end

    # Denied "rules"
    denied.each do |deny_proto|
      ipprotocol = deny_proto.dig('IPProtocol') || "all"
      if deny_proto.dig('ports')
        # Create just the protocol rel for each port/port-range
        ports = deny_proto.dig('ports')
        ports.each do |deny_port|
          if deny_port =~ /\d+\-\d+/
            from_port = deny_port.split('-')[0].to_i
            to_port = deny_port.split('-')[1].to_i
          else
            from_port = deny_port.to_i
            to_port = deny_port.to_i
          end

          firewall_rule_relationship(@asset_label, @asset_name, "GCP_COMPUTE_NETWORKPROTOCOL", ipprotocol, "compute.googleapis.com/NetworkProtocol", "HAS_FIREWALLRULE", "deny", from_port, to_port)

        end
      else
        # Create just the protocol rel with default ports
        firewall_rule_relationship(@asset_label, @asset_name, "GCP_COMPUTE_NETWORKPROTOCOL", ipprotocol, "compute.googleapis.com/NetworkProtocol", "HAS_FIREWALLRULE", "deny", 0, 65535)
      end
    end
  end

  private

  def firewall_rule_relationship(match_label, match_name, merge_label, merge_name, asset_type, relationship, action, from_port, to_port)
    query = """
      MATCH (f:#{match_label} { name: \"#{match_name}\" })
      MERGE (a:#{merge_label} { name: \"#{merge_name}\" })
      ON CREATE SET a.asset_type = \"#{asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\"
      ON MATCH SET  a.asset_type = \"#{asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\"
      MERGE (f)-[:#{relationship} { action: \"#{action}\", from_port: #{from_port}, to_port: #{to_port} }]->(a)
    """
    graphquery(query)
  end
end
