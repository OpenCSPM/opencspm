# require 'json'
# require 'redis'
# require 'redisgraph'
# require 'awesome_print'
require 'rg/aws_graph_db_loader.rb'
require 'rg/loaders.rb'

class Rg
  DEBUG_LOG_FILE = 'tmp/redisgraph.log'.freeze
  # TYPES = %w[
  #   instance
  #   vpc
  #   security_group
  #   network_interface
  #   subnet
  #   address
  #   nat_gateway
  #   route_table
  #   image
  #   snapshot
  #   flow_log
  #   volume
  #   vpn_gateway
  #   peering_connection
  # ].freeze
  TYPES = %w[
    instance
    vpc
    security_group
    network_interface
    subnet
  ].freeze

  def initialize
    @r = RedisGraph.new('recon')
  end

  #
  # Execute a Cypher query
  #
  def query(q)
    # _log(q)
    res = @r.query(q)
    printf '.'
    # p res.stats if res
  end

  def delete_all
    puts 'Deleting all RedisGraph nodes...'
    q = 'MATCH (n) DETACH DELETE n'
    res = query(q)
  end

  def create_all
    c = 0

    puts "\nLoading all RedisGraph nodes..."

    # read recon .json
    time_start = _time

    #
    # Load AWS Recon .json file
    #
    IO.foreach(Rails.root.join('tmp', 'recon.json')) do |line|
      json = JSON.parse(line, object_class: OpenStruct)

      # binding.pry

      if json.service.downcase == 'ec2' && TYPES.include?(json.asset_type)
        # if json.service.downcase == 'ec2'

        # TODO: AWSLoader::EC2::Instance
        # TODO: AWSLoader::EC2::Vpc
        # TODO: AWSLoader::EC2::SecurityGroup
        # TODO: AWSLoader::EC2::NetworkInterface
        AwsEc2Loader.new(json).to_q&.each do |q|
          # binding.pry
          # puts q
          query(q)
          c += 1
        end
      end
    end

    puts "\nQueries: #{c}"
    puts "Elapsed time: #{_time - time_start}"
  end

  # DEBUG
  def _clear_log
    File.write(DEBUG_LOG_FILE, '', mode: 'w')
  end

  private

  # DEBUG
  def _log(msg)
    File.write(DEBUG_LOG_FILE, msg, mode: 'a')
  end

  # DEBUG
  def _time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
