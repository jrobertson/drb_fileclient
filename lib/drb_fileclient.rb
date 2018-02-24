#!/usr/bin/env ruby

# file: drb_fileclient.rb

require 'drb'


class DRbFileClient

  def initialize(host: 'localhost', port: '61010')
    
    DRb.start_service

    # attach to the DRb server via a URI given on the command line
    @file = DRbObject.new nil, "druby://#{host}:#{port}"
    
  end
  
  def exists?(filename)
    
    @file.exists? filename
    
  end

  def read(filename)
    
    @file.read filename
    
  end
  
  def write(filename, s)
    
    @file.write filename, s
    
  end  

end 
