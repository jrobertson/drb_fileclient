#!/usr/bin/env ruby

# file: drb_fileclient.rb

require 'drb'


class DRbFileClient

  def initialize(location=nil, host: nil, port: '61010')
    
    if location then
      
      host = location[/(?<=^dfs:\/\/)[^\/:]+/]
      port = location[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'
      @directory = location[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]
      
    end
    
    DRb.start_service
    
  end
  
  def chdir(raw_path)
    
    directory = if raw_path[0] == '/'  then
      raw_path[1..-1]
    elsif raw_path =~ /^dfs:\/\//
      parse_path(raw_path)
    else      
      File.join(@directory, raw_path)
    end    
    
    if @file.exists? directory then
      @directory = directory
    else
      'No such file or directory'
    end
    
  end  
  
  def exists?(filename=@filename)  
    
    filename2 = if filename =~ /^dfs:\/\// then
      parse_path(filename)
    else
      filename
    end

    @file.exists?(File.join(@directory, filename2)) if @directory
    
  end
  
  def mkdir(name)
    path = parse_path(name)
    @file.mkdir path
  end
  
  def mkdir_p(raw_path)
    path = parse_path(raw_path)
    @file.mkdir_p path
  end  
  
  def pwd()
    
    '/' + @directory if @file
    
  end  

  def read(filename=@filename)
    
    path = if filename =~ /^dfs:\/\// then
      parse_path(filename)
    else
      File.join(@directory, filename)
    end
    
    @file.read path
  end
  
  def write(filename=@filename, s)
        
    path = if filename =~ /^dfs:\/\// then
      parse_path(filename)
    else
      File.join(@directory, filename)
    end
    
    @file.write path, s     
    
  end

  private
  
  def parse_path(filename)

    host = filename[/(?<=^dfs:\/\/)[^\/:]+/]
    port = filename[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'

    @file = DRbObject.new nil, "druby://#{host}:#{port}"
    filename[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]          

  end

end 

class DfsFile
  
  @client = DRbFileClient.new
  
  def self.exists?(filename)
    @client.exists?(filename)
  end
  
  def self.chdir(path)
    @client.chdir(path)
  end    
    
  def self.mkdir(name)
    @client.mkdir(name)
  end  
  
  def self.mkdir_p(path)
    @client.mkdir_p(path)
  end       
  
  def self.pwd()
    @client.pwd()
  end     
  
  def self.read(filename)
    @client.read(filename)
  end
  
  def self.write(filename, s)
    @client.write(filename, s)
  end
  
end
