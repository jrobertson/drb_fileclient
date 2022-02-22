#!/usr/bin/env ruby

# file: drb_fileclient.rb

require 'zip'
require 'dir-to-xml'
require 'drb_fileclient-readwrite'


class DRbFileClient < DRbFileClientReadWrite
  using ColouredText

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

  def ru(path)

    return DirToXML.new(path, verbose: false).latest unless @directory \
        or path =~ /^dfs:\/\//

    if path =~ /^dfs:\/\// then
      @file, path2, addr = parse_path(path)
    else
      path2 = File.join(@directory, path)
    end

    found = @file.ru  path2
    return (addr + found) if found and addr

  end

  def ru_r(path)

    unless @directory or path =~ /^dfs:\/\// then
      return DirToXML.new(path, recursive: true, verbose: false).latest
    end

    if path =~ /^dfs:\/\// then
      @file, path2, addr = parse_path(path)
    else
      path2 = File.join(@directory, path)
    end

    found = @file.ru_r  path2
    return (addr + found) if found and addr

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

end


def DfsFile.directory?(filename)
  DRbFileClient.new.directory?(filename)
end
def DfsFile.chdir(path)
  DRbFileClient.new.chdir(path)
end
def DfsFile.chmod(num, filename)
  DRbFileClient.new.chmod(num, filename)
end
def DfsFile.cp(path, path2)
  DRbFileClient.new.cp(path, path2)
end
def DfsFile.ls(path)
  DRbFileClient.new.ls(path)
end
def DfsFile.mv(path, path2)
  DRbFileClient.new.mv(path, path2)
end
def DfsFile.pwd()
  DRbFileClient.new.pwd()
end
def DfsFile.ru(path)
  DRbFileClient.new.ru(path)
end
def DfsFile.ru_r(path)
  DRbFileClient.new.ru_r(path)
end
def DfsFile.zip(filename, a)
  DRbFileClient.new.zip(filename, a)
end
