# require 'json'
# require 'redis'
# require 'redisgraph'
# require 'awesome_print'
require 'rg/aws_graph_db_loader.rb'
require 'rg/loaders.rb'

class Rg
  def initialize
    @r = RedisGraph.new('recon')
  end

  #
  # Execute a Cypher query
  #
  def query(q)
    res = @r.query(q)
    # p res.stats if res
  end

  def delete_all
    puts 'Deleting all RedisGraph nodes...'
    q = 'MATCH (n) DETACH DELETE n'
    res = query(q)
  end

  def create_all
    puts 'Loading all RedisGraph nodes...'

    # read recon .json
    time_start = _time

    IO.foreach(Rails.root.join('tmp', 'recon.json')) do |line|
      json = JSON.parse(line, object_class: OpenStruct)

      # binding.pry

      if json.service.downcase == 'ec2'
        # binding.pry
        q = AwsEc2Loader.new(json).to_q

        if q
          # puts q
          query(q)
        end
      end

      # insert(json) if types.include?(json.asset_type)
    end

    puts "Elapsed time: #{_time - time_start}"
  end

  def insert(res)
    resource = res.asset_type

    # basic sanity check
    return unless res.name &&
                  res.region &&
                  res.service &&
                  (res.resource.data.instance_type || res.resource.data.vpc_id)

    #
    # EC2 Instances
    #
    if res.resource.data.instance_type
      q = %{
          MERGE (i:AWS_INSTANCE { name: '#{res.name}' })
          ON CREATE SET
              i.service_type = '#{res.service}',
              i.asset_type = '#{resource}',
              i.loader_type = 'aws',
              i.instance_type = '#{res.resource.data.instance_type}'
          ON MATCH SET
              i.service_type = '#{res.service}',
              i.asset_type = '#{resource}',
              i.loader_type = 'aws',
              i.instance_type = '#{res.resource.data.instance_type}'
      }

      # print q
      printf '[.]'

      res_instance = @r.query(q)
    end

    #
    # EC2 vpc -> Region relationships
    # EC2 instance -> Region relationships
    #
    if res.region
      # vpc -> region
      q = %{
        MATCH (v:AWS_VPC { name: '#{res.name}' })
        MERGE (r:AWS_REGION { name: '#{res.region}' })
        ON CREATE SET
            r.asset_type = 'region',
            r.loader_type = 'aws'
        ON MATCH SET
            r.asset_type = 'region',
            r.loader_type = 'aws'
        MERGE (v)-[:LIVES_IN]->(r)
      }

      printf '->'
      res_vpc_region = @r.query(q)

      # instance -> region
      q = %{
        MATCH (i:AWS_INSTANCE { name: '#{res.name}' })
        MERGE (r:AWS_REGION { name: '#{res.region}' })
        ON CREATE SET
            r.asset_type = 'region',
            r.loader_type = 'aws'
        ON MATCH SET
            r.asset_type = 'region',
            r.loader_type = 'aws'
        MERGE (i)-[:RUNS_IN]->(r)
      }

      printf '->'
      res_instance_region = @r.query(q)
    end

    #
    # EC2 instance -> VPC relationships
    #
    if res.resource.data.vpc_id
      q = %{
      MATCH (i:AWS_INSTANCE { name: '#{res.name}' })
      MERGE (r:AWS_VPC { name: '#{res.resource.data.vpc_id}' })
      ON CREATE SET
          r.region = '#{res.region}',
          r.asset_type = 'vpc',
          r.loader_type = 'aws'
      ON MATCH SET
          r.region = '#{res.region}',
          r.asset_type = 'vpc',
          r.loader_type = 'aws'
      MERGE (i)-[:IS_MEMBER_OF]->(r)
    }

      printf '->'
      res_vpcs = @r.query(q)
    end

    true
  end
  puts '!!!'

  private

  def _time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end

# z = Rg.new
# z.delete_all
# z.create_all
