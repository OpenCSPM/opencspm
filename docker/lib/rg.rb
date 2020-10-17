# require 'json'
# require 'redis'
# require 'redisgraph'
# require 'awesome_print'

class Rg
  def initialize
    @r = RedisGraph.new('recon')
  end

  def delete_all
    q = 'MATCH (n) DETACH DELETE n'
    res = @r.query(q)
    res.stats
  end

  def create_all
    # type we care about
    # types = %w[instance cluster]
    types = %w[instance]

    resources = []

    # read recon .json
    t = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    IO.foreach(Rails.root.join('tmp', 'recon.json')) do |line|
      json = JSON.parse(line, object_class: OpenStruct)
      # p json if types.include?(json.asset_type)

      # puts json.name if types.include?(json.asset_type) && insert(json)
      insert(json) if types.include?(json.asset_type)
    end

    p Process.clock_gettime(Process::CLOCK_MONOTONIC) - t
  end

  def insert(res)
    resource = res.asset_type
    relationship = 'runs_in'

    stuff = [
      { instance_id: 'i-124243', hostname: 'dev-test-1' },
      { instance_id: 'i-224243', hostname: 'dev-test-2' },
      { instance_id: 'i-324243', hostname: 'dev-test-3' }
    ].to_json

    stuff = 'tbd'

    # basic sanity check
    return unless res.name &&
                  res.region &&
                  res.resource.data.instance_type

    region = %w[us-east-1 us-east-2 us-east-3].sample

    # q = "(:instance {name:'i-a1b2c3d4e5f6', type: 'x1e.16xlarge'})-[:runs_in]->(:region {name:'us-east-2'})," \

    # q = %{
    #   MERGE (i:#{resource} { name: '#{res.name}' })
    #   ON CREATE SET
    #       i.asset_type = \"#{resource}\",
    #       i.loader_type = \"aws\",
    #       i.instance_type = \"#{res.resource.data.instance_type}\"
    #   ON MATCH SET
    #       i.asset_type = \"#{resource}\",
    #       i.loader_type = \"aws\",
    #       i.instance_type = \"#{res.resource.data.instance_type}\"
    #   MERGE (r:AWS_REGION { name: \"#{region}\" })
    #   ON CREATE SET
    #       r.asset_type = \"aws_non_china_region\",
    #       r.loader_type = \"aws\"
    #   ON MATCH SET
    #       r.asset_type = \"aws_non_china_region\",
    #       r.loader_type = \"aws\"
    #   MERGE (i)-[:#{relationship.upcase}]->(r)
    #   }

    q = %{
        MERGE (i:#{resource} { name: '#{res.name}' })
        ON CREATE SET
            i.asset_type = '#{resource}',
            i.loader_type = 'aws',
            i.instance_type = '#{res.resource.data.instance_type}'
        ON MATCH SET
            i.asset_type = '#{resource}',
            i.loader_type = 'aws',
            i.instance_type = '#{res.resource.data.instance_type}'
    }

    print q

    # 'CREATE ' \
    # "(#{resource} { name: '#{res.name}', type: '#{res.resource.data.instance_type}' })-[#{relationship}]->(:region { name: '#{region}' })"

    # ap q
    res_instance = @r.query(q)
    # res.stats

    q = %{
      MATCH (i:#{resource} { name: \"#{res.name}\" })
      MERGE (r:AWS_REGION { name: \"#{region}\" })
      ON CREATE SET
          r.asset_type = \"aws_non_china_region\",
          r.loader_type = \"aws\"
      ON MATCH SET
          r.asset_type = \"aws_non_china_region\",
          r.loader_type = \"aws\"
      MERGE (i)-[:#{relationship.upcase}]->(r)
    }

    res_region = @r.query(q)
    # res = @r.query(q)

    !!res_instance && !!res_region
    # !!res
  end
end

# z = Rg.new
# z.delete_all
# z.create_all
