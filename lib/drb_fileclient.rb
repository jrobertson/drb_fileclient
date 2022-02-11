#!/usr/bin/env ruby

# file: drb_fileclient.rb

require 'drb'
require 'zip'
require 'c32'
# Commented out to avoid bug with RXFHelper constants
#require 'dir-to-xml'


class DRbFileClient
  using ColouredText

  def initialize(location=nil, host: nil, port: '61010', debug: false)

    @debug = debug

    if location then

      host = location[/(?<=^dfs:\/\/)[^\/:]+/]
      port = location[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'
      @directory = location[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]

    end

    DRb.start_service

  end

  def chdir(raw_path)

    return Dir.chdir raw_path unless @directory or raw_path =~ /^dfs:\/\//

    if raw_path[0] == '/'  then
      directory = raw_path[1..-1]
    elsif raw_path =~ /^dfs:\/\//
      @file, directory = parse_path(raw_path)
    else
      directory = File.join(@directory, raw_path)
    end

    if @file.exists? directory then
      @directory = directory
    else
      'No such file or directory'
    end

  end

  def chmod(permissions, raw_path)

    if raw_path =~ /^dfs:\/\// then

      @file, path = parse_path(raw_path)
      @file.chmod permissions, path

    else
      return FileUtils.chmod(permissions, raw_path)
    end
  end

  def cp(raw_path, raw_path2)

    puts 'inside cp'.info if @debug

    if raw_path =~ /^dfs:\/\// then

      if @debug then
        puts ('raw_path: ' + raw_path.inspect).debug
        puts ('raw_path2: ' + raw_path2.inspect).debug
      end

      if raw_path[/^dfs:\/\/([^\/]+)/] == raw_path2[/^dfs:\/\/([^\/]+)/] then

        _, path = parse_path(raw_path)
        @file, path2 = parse_path(raw_path2)
        @file.cp path, path2

      elsif raw_path2[/^dfs:\/\//]

        @file, path = parse_path(raw_path)
        file2, path2 = parse_path(raw_path2)
        puts ('path: ' + path.inspect).debug if @debug
        puts ('path2: ' + path.inspect).debug if @debug
        content = @file.read path

        file2.write path2, content

      else

        @file, path = parse_path(raw_path)
        #file2, path2 = parse_path(raw_path2)
        puts ('path: ' + path.inspect).debug if @debug
        puts ('path2: ' + path2.inspect).debug if @debug
        content = @file.read path

        File.write raw_path2, content

      end

    elsif raw_path2 =~ /dfs:\/\// then

      puts 'option2'.info if @debug

      file2, path2 = parse_path(raw_path2)
      puts ('path2: ' + path2.inspect).debug if @debug
      file2.write path2, File.read(raw_path)

    else

      puts 'option3'.info if @debug
      FileUtils.cp raw_path, raw_path2

    end

  end

  def directory?(filename=@filename)

    return File.directory? filename unless @directory or filename =~ /^dfs:\/\//

    if filename =~ /^dfs:\/\// then
      @file, filename2 = parse_path(filename)
    else

      filename2 = File.join(@directory, filename)
    end

    @file.directory?(filename2)

  end

  def exists?(filename=@filename)

    return File.exists? filename unless @directory or filename =~ /^dfs:\/\//

    if filename =~ /^dfs:\/\// then
      @file, filename2 = parse_path(filename)
    else

      filename2 = File.join(@directory, filename)
    end

    @file.exists?(filename2)

  end

  alias exist? exists?

  def glob(s)

    if s =~ /^dfs:\/\// then
      @file, s2 = parse_path(s)
    else
      s2 = File.join(@directory, s)
    end

    @file.glob s2

  end

  def ls(raw_path)

    return Dir[raw_path] unless @directory or raw_path =~ /^dfs:\/\//

    if raw_path[0] == '/'  then
      path = raw_path[1..-1]
    elsif raw_path =~ /^dfs:\/\//
      @file, path = parse_path(raw_path)
    else
      path = File.join(@directory, raw_path)
    end

    @file.ls path

  end

  def mkdir(name)

    return FileUtils.mkdir name unless @directory or name =~ /^dfs:\/\//

    @file, path = parse_path(name)
    @file.mkdir path
  end

  def mkdir_p(raw_path)

    unless @directory or raw_path =~ /^dfs:\/\// then
      return FileUtils.mkdir_p raw_path
    end

    if raw_path =~ /^dfs:\/\// then
      @file, filepath = parse_path(raw_path)
    else
      filepath = File.join(@directory, raw_path)
    end

    @file.mkdir_p filepath
  end

  def mv(raw_path, raw_path2)

    unless @directory or raw_path =~ /^dfs:\/\// then
      return FileUtils.mv raw_path, raw_path2
    end

    if raw_path =~ /^dfs:\/\// then
      _, path = parse_path(raw_path)
    else
      path = File.join(@directory, raw_path)
    end

    if raw_path2 =~ /^dfs:\/\// then
      _, path2 = parse_path(raw_path2)
    else
      path2 = File.join(@directory, raw_path2)
    end

    @file.mv path, path2
  end

  def pwd()

    return Dir.pwd unless @directory

    '/' + @directory if @file

  end

  def read(filename=@filename)

    return File.read filename, s unless @directory or filename =~ /^dfs:\/\//

    if filename =~ /^dfs:\/\// then
      @file, path = parse_path(filename)
    else
      path = File.join(@directory, filename)
    end

    @file.read path
  end

  def rm(path)

    return FileUtils.rm path unless @directory or path =~ /^dfs:\/\//

    if path =~ /^dfs:\/\// then
      @file, path2 = parse_path( path)
    else
      path2 = File.join(@directory, path)
    end

    @file.rm  path2

  end

  def rm_r(path, force: false)

    unless @directory or path =~ /^dfs:\/\// then
      return FileUtils.rm_r(path, force: force)
    end

    if path =~ /^dfs:\/\// then
      @file, path2 = parse_path( path)
    else
      path2 = File.join(@directory, path)
    end

    @file.rm_r(path2, force: force)

  end

  def ru(path)

    return DirToXML.new(path, verbose: false).latest unless @directory \
        or path =~ /^dfs:\/\//

    if path =~ /^dfs:\/\// then
      @file, path2 = parse_path( path)
    else
      path2 = File.join(@directory, path)
    end

    @file.ru  path2

  end

  def ru_r(path)

    unless @directory or path =~ /^dfs:\/\// then
      return DirToXML.new(path, recursive: true, verbose: false).latest
    end

    if path =~ /^dfs:\/\// then
      @file, path2 = parse_path( path)
    else
      path2 = File.join(@directory, path)
    end

    @file.ru_r  path2

  end

  def touch(s, mtime: Time.now)

    unless @directory or s =~ /^dfs:\/\// then
      return FileUtils.touch(s, mtime: mtime)
    end

    if s =~ /^dfs:\/\// then
      @file, s2 = parse_path(s)
    else
      s2 = File.join(@directory, s)
    end

    @file.touch s2, mtime: mtime

  end

  def write(filename=@filename, s)

    return File.write filename, s unless @directory or filename =~ /^dfs:\/\//

    if filename =~ /^dfs:\/\// then
      @file, path = parse_path(filename)
    else
      path = File.join(@directory, filename)
    end

    @file.write path, s

  end

  def zip(filename_zip, a)

    puts '@directory: ' + @directory.inspect if @debug

    unless @directory or filename_zip =~ /^dfs:\/\// then

      Zip::File.open(zipfile_zip, Zip::File::CREATE) do |x|

        a.each do |filename, buffer|
          x.get_output_stream(filename) {|os| os.write buffer }
        end

      end

    end

    if filename_zip =~ /^dfs:\/\// then
      @file, filepath = parse_path(filename_zip)
    else
      filepath = File.join(@directory, filename_zip)
    end

    @file.zip filepath, a

  end

  private

  def parse_path(filename)

    host = filename[/(?<=^dfs:\/\/)[^\/:]+/]
    @host = host if host

    port = filename[/(?<=^dfs:\/\/)[^:]+:(\d+)/,1]  || '61010'

    file_server = DRbObject.new nil, "druby://#{host || @host}:#{port}"
    [file_server, filename[/(?<=^dfs:\/\/)[^\/]+\/(.*)/,1]]

  end

end

class DfsFile

  @client = DRbFileClient.new

  def self.directory?(filename) @client.directory?(filename) end
  def self.exists?(filename)    @client.exists?(filename)    end
  def self.chdir(path)          @client.chdir(path)          end
  def self.chmod(num, filename) @client.chmod(num, filename) end
  def self.cp(path, path2)      @client.cp(path, path2)      end
  def self.glob(s)              @client.glob(s)              end
  def self.ls(path)             @client.ls(path)             end
  def self.mkdir(name)          @client.mkdir(name)          end
  def self.mkdir_p(path)        @client.mkdir_p(path)        end
  def self.mv(path, path2)      @client.mv(path, path2)      end
  def self.pwd()                @client.pwd()                end
  def self.read(filename)       @client.read(filename)       end
  def self.rm(filename)         @client.rm(filename)         end

  def self.rm_r(filename, force: false)
    @client.rm_r(filename, force: force)
  end

  def self.ru(path)             @client.ru(path)             end
  def self.ru_r(path)           @client.ru_r(path)           end

  def self.touch(filename, mtime: Time.now)
    @client.touch(filename, mtime: mtime)
  end

  def self.write(filename, s)   @client.write(filename, s)   end
  def self.zip(filename, a)     @client.zip(filename, a)     end

end
