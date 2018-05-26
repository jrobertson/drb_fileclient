#!/usr/bin/env ruby

# file: drb_fileclient.rb

require 'drb'


class DRbFileClient

  def initialize(location=nil, host: nil, port: '61010')
    
    if location then
      
      host = location[/(?<=^dfs:\/\/)[^\/:]+/]
      port = location[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'
      @filename = location[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]
      
    end
    
    DRb.start_service

    # attach to the DRb server via a URI given on the command line
    @file = DRbObject.new nil, "druby://#{host}:#{port}" if host
    
  end
  
  def exists?(filename=@filename)  
    
    filename2 = parse_path(filename)
    @file.exists? filename2
    
  end

  def read(filename=@filename)
    
    filename2 = parse_path(filename)
    @file.read filename2
    
  end
  
  def write(filename=@filename, s)
    
    filename2 = parse_path(filename)
    @file.write filename2, s
    
  end

  private
  
  def parse_path(filename)
    
    if @file then
      
      filename
      
    else
      
      host = filename[/(?<=^dfs:\/\/)[^\/:]+/]
      port = filename[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'

      @file = DRbObject.new nil, "druby://#{host}:#{port}"
      filename[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]      
      
    end    
    
  end

end 

class DfsFile
  
  def self.exists?(filename)
    DRbFileClient.new(filename).exists?
  end
  
  def self.read(filename)
    DRbFileClient.new.read(filename)
  end
  
  def self.write(filename, s)
    DRbFileClient.new.write(filename, s)
  end
  
end
