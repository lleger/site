require 'yaml'
require 'fileutils'
require 'digest'
require 'fog'
require 'mime/types'

class Jekyll < Thor
  include FileUtils
  include Thor::Actions

  desc "draft NAME", "create a new draft post"
  def draft(name)
    slug = name.downcase.gsub(/ +/,'-').gsub(/[^-\w]/,'').sub(/-+$/,'')
    file = "_drafts/" + slug + ".mdown"
    mkdir_p "_drafts"
    if File.exists?(file)
      say_status("error", "#{file} already exists", :red)
      if file_collision(file)
        remove_file(file)
      else
        return
      end
    end
    create_file file do
      <<-EOS.gsub(/^ {6}/, '')
      ---
      layout: post
      title: #{name}
      ---
      EOS
    end
  end
  
  desc "drafts", "list all drafts"
  def drafts
    headers = [["Date", "Name"], ["----", "----"]]
    print_table(headers + Dir["_drafts/*"].map { |d| [File.mtime(d).strftime("%m/%d/%Y"), d] })
  end

  desc "post [FILE]", "turn a draft into a post"
  method_option :latest, aliases: "-l", type: :boolean, default: false, desc: "post latest draft"
  def post(file = nil)
    if options.latest?
      file = Dir.glob("_drafts/*").max_by { |f| File.mtime(f) }
    elsif file
      if !File.exists?(file)
        say_status("error", "#{file} doesn't exist", :red)
      end
    else
      files = Dir["_drafts/*"]
      files_array = Array[]
      files.each_with_index { |f, i| files_array << [i, f] }
      print_table(files_array)
      choice = ask("Choose a draft to post:", :blue)
    end
    draft = file || files_array[choice.to_i][1]
    now = Date.today.strftime("%Y-%m-%d").gsub(/-0/,'-')
    mv draft, "_posts/#{now}-#{File.basename(draft)}"
  end
  
  desc "posts", "list all posts"
  def posts
    headers = [["Date", "Name"], ["----", "----"]]    
    print_table(headers + Dir["_posts/*"].map { |p| [File.mtime(p).strftime("%m/%d/%Y"), p] })
  end
  
  desc "publish", "sync to S3/Cloudfront"
  def publish
    config = YAML.load_file('_s3.yml')
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => config['s3_id'],
      :aws_secret_access_key    => config['s3_secret']
    })
    bucket = connection.directories.get(config['s3_bucket'])
    file_metadata = { content_encoding: "gzip" }
    files_in_s3 = bucket.files.map(&:key)
    files_local = Dir["_site/**/*.[^r]*"].map { |file| file.gsub(/_site\//, "") } 
    files_in_s3_but_not_local = files_in_s3 - files_local
    files_local_but_not_in_s3 = files_local - files_in_s3
    files_changed = Array[]
    
    # Ask to delete files not found locally but are in S3
    files_in_s3_but_not_local.each do |file|
      choice = ask("#{file} not found locally but is in S3, delete from S3? (Y or N)")
      if choice == "Y"
        bucket.files.get(file).destroy 
        files_changed << file        
        say_status("delete", file, :red)
      end
    end
    
    # Upload changed files
    (files_in_s3 & files_local).each do |file|
      local_file = File.join("_site", file)
      s3_file = bucket.files.get(file)
      local_md5 = Digest::MD5.hexdigest(File.read(local_file))
      s3_md5 = s3_file.etag
      if s3_md5 != local_md5
        gzip_file(local_file)
        s3_file.body = File.read(local_file)
        s3_file.metadata = file_metadata.merge!(content_type: MIME::Types.type_for(local_file).first.content_type)
        s3_file.save
        files_changed << file
        say_status("upload", file, :green)        
      end
    end
    
    # Upload new files
    files_local_but_not_in_s3.each do |file|
      s3_file = bucket.files.new
      s3_file.key = file
      local_file = File.join("_site", file)
      gzip_file(local_file)
      s3_file.body = File.read(local_file)
      s3_file.metadata = file_metadata.merge!(content_type: MIME::Types.type_for(local_file).first.content_type)
      s3_file.save
      files_changed << file      
      say_status("upload", file, :green)
    end
    
    # Invalidate Cloudfront
    if files_changed.empty?
      say_status("finished", "Nothing to publish", :blue)
    else
      say_status("invalidate", "Cloudfront distribution in progress", :blue)
      cdn = Fog::CDN.new({
        :provider               => 'AWS',
        :aws_access_key_id      => config['s3_id'],
        :aws_secret_access_key  => config['s3_secret']
      })
      data = cdn.post_invalidation(config['cf_distribution'], files_changed.map { |file| "/" + file })
      invalidation_id = data.body['Id']

      Fog.wait_for { 
        cdn.get_invalidation(config['cf_distribution'], invalidation_id).body['Status'] == 'Completed'
      }
      say_status("invalidate", "Cloudfront distribution", :green)  
    end
  end
  
  private
  
  def gzip_file(filename)
    `gzip -9 #{filename}`
    mv filename + ".gz", filename
  end
end