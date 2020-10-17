class GCP_COMPUTE_ROUTE < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    if asset.dig('resource','data', 'selfLink')
      asset.dig('resource', 'data').delete('selfLink')
    end
    route = asset.dig('resource').delete('data')

    compute_from_network_name = compute_url_to_compute_name(route['network'])
    compute_to_gateway_name = compute_url_to_compute_name(route['nextHopGateway']) unless route['nextHopGateway'].nil?
    compute_to_network_name = compute_url_to_compute_name(route['nextHopNetwork']) unless route['nextHopNetwork'].nil?

    # Create FROM network
    query = """
      MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_from_network_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
    """
    graphquery(query)
 
    unless compute_to_network_name.nil?
      # Create TO network and relationship
      query = """
        MATCH (t:GCP_COMPUTE_NETWORK { name: \"#{compute_from_network_name}\" })
        MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_to_network_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (t)-[:HAS_ROUTE {name: \"#{route['name']}\", creationTimestamp: \"#{route['creationTimestamp']}\", description: \"#{route['description']}\", destRange: \"#{route['destRange']}\", id: \"#{route['id']}\", priority: #{route['priority']} }]->(a)
      """
      graphquery(query)
    end

    unless compute_to_gateway_name.nil?
      # Create TO gateway and relationship
      query = """
        MATCH (t:GCP_COMPUTE_NETWORK { name: \"#{compute_from_network_name}\" })
        MERGE (a:GCP_COMPUTE_GATEWAY { name: \"#{compute_to_gateway_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/NetworkGateway\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"compute.googleapis.com/NetworkGateway\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (t)-[:HAS_ROUTE {name: \"#{route['name']}\", creationTimestamp: \"#{route['creationTimestamp']}\", description: \"#{route['description']}\", destRange: \"#{route['destRange']}\", id: \"#{route['id']}\", priority: #{route['priority']} }]->(a)
      """
      graphquery(query)
    end
  end
end
