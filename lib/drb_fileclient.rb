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
    
    return Dir.chdir raw_path unless @directory or raw_path =~ /^dfs:\/\//
    
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

  def cp(raw_path, raw_path2)
    
    unless @directory or raw_path =~ /^dfs:\/\// then
      return FileUtils.cp raw_path, raw_path2 
    end
    
    path, path2 = if raw_path =~ /^dfs:\/\// then
      [parse_path(raw_path), parse_path(raw_path2)]
    else
      [File.join(@directory, raw_path), File.join(@directory, raw_path2)]
    end 
      
    @file.cp path, path2
  end   
  
  def exists?(filename=@filename)  
    
    return File.exists? filename unless @directory or filename =~ /^dfs:\/\//
    
    filename2 = if filename =~ /^dfs:\/\// then
      parse_path(filename)
    else

      File.join(@directory, filename)
    end

    @file.exists?(filename2)
    
  end
  
  alias exist? exists?
  
  def mkdir(name)
    
    return FileUtils.mkdir name unless @directory or name =~ /^dfs:\/\//
    
    path = parse_path(name)
    @file.mkdir path
  end
  
  def mkdir_p(raw_path)
    
    unless @directory or raw_path =~ /^dfs:\/\// then
      return FileUtils.mkdir_p raw_path 
    end
    
    path = parse_path(raw_path)
    @file.mkdir_p path
  end  
  
  def mv(raw_path, raw_path2)
    
    unless @directory or raw_path =~ /^dfs:\/\// then
      return FileUtils.mv raw_path, raw_path2  
    end
    
    path, path2 = if raw_path =~ /^dfs:\/\// then
      [parse_path(raw_path), parse_path(raw_path2)]
    else
      [File.join(@directory, raw_path), File.join(@directory, raw_path2)]
    end 
      
    @file.mv path, path2
  end  
  
  def pwd()
    
    return Dir.pwd unless @directory
    
    '/' + @directory if @file
    
  end  

  def read(filename=@filename)
    
    return File.read filename, s unless @directory or filename =~ /^dfs:\/\//
    
    path = if filename =~ /^dfs:\/\// then
      parse_path(filename)
    else
      File.join(@directory, filename)
    end
    
    @file.read path
  end
  
  def rm(path)
    
    return FileUtils.rm path unless @directory or path =~ /^dfs:\/\//
    
    path2 = if path =~ /^dfs:\/\// then
      parse_path( path)
    else
      File.join(@directory, path)
    end
      
    @file.rm  path2
    
  end    
  
  def write(filename=@filename, s)
        
    return File.write filename, s unless @directory or filename =~ /^dfs:\/\//
    
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
  
  def self.exists?(filename)  @client.exists?(filename)  end  
  def self.chdir(path)        @client.chdir(path)        end  
  def self.cp(path, path2)    @client.cp(path, path2)    end         
  def self.mkdir(name)        @client.mkdir(name)        end    
  def self.mkdir_p(path)      @client.mkdir_p(path)      end       
  def self.mv(path, path2)    @client.mv(path, path2)    end     
  def self.pwd()              @client.pwd()              end       
  def self.read(filename)     @client.read(filename)     end
  def self.rm(filename)       @client.rm(filename)       end  
  def self.write(filename, s) @client.write(filename, s) end
  
end
