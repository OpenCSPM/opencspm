# require 'json'
# require 'redis'
# require 'redisgraph'
# require 'awesome_print'
require 'rg/aws_graph_db_loader.rb'
require 'rg/aws_loader.rb'

#
# Test RedisGraph Loader for AWS Recon assets
#
# Usage: bundle exec rails graph:load
#
class Rg
  DEBUG_LOG_FILE = 'tmp/redisgraph.log'.freeze

  def initialize
    @r = RedisGraph.new('recon')
  end

  #
  # Execute a Cypher query
  #
  def query(q)
    # _log(q)
    res = @r.query(q)
    printf "\x1b[32m.\x1b[0m"
    # p res.stats if res
  end

  def delete_all
    puts 'Deleting all RedisGraph nodes...'
    q = 'MATCH (n) DETACH DELETE n'
    res = query(q)
  end

  def create_all
    # c = 0
    query_stats = {}
    missing_stats = {}

    puts "\nLoading all RedisGraph nodes..."

    time_start = _time

    #
    # Load AWS Recon .json file
    #
    IO.foreach(Rails.root.join('tmp', 'recon.json')) do |line|
      json = JSON.parse(line, object_class: OpenStruct)

      # Instantiate a Loader instance for each service type
      begin
        aws_loader = Object.const_get("AWSLoader::#{json.service}")
        loader = aws_loader.new(json)

        # DEBUG: skip loader methods that aren't implemented yet
        unless loader.respond_to?(json.asset_type)
          # puts "No #{json.service} loader defined for asset type: #{json.asset_type}"
          next
        end

        # call loader method for the asset type
        loader.send(json.asset_type)&.each do |q|
          # binding.pry if json.asset_type == 'db_cluster' && json.service == 'RDS'
          query(q)
          query_stats[json.service] = query_stats[json.service] ? query_stats[json.service] + 1 : 1

          # print "\r#{query_stats.map { |k, v| "#{k}: #{v}" }}"
        end
      rescue NameError
        # puts "No loader defined for service: #{json.service}"
        missing_stats[json.service] = missing_stats[json.service] ? missing_stats[json.service] + 1 : 1
      end
    end

    puts "\nResources: #{query_stats.values.reduce(:+)}"
    puts "\nQueries: (#{query_stats.keys.count}):"
    p query_stats.sort_by { |_k, v| -v }.each { |k, v| puts "#{k}: \x1b[32m#{v}\x1b[0m\n" }
    puts "\nMissing services (#{missing_stats.keys.count}):"
    p missing_stats
    puts "\nElapsed time: #{_time - time_start}"
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
