require 'fileutils'

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
      layout: post"
      title: #{name}"
      ---
      EOS
    end
  end
  
  desc "drafts", "list all drafts"
  def drafts
    print_table(Dir["_drafts/*"].map { |d| [d] })
  end

  desc "publish [FILE]", "publish a draft"
  method_option :latest, aliases: "-l", type: :boolean, default: false, desc: "publish latest draft"
  def publish(file = nil)
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
      choice = ask("Choose a draft to publish:", :blue)
    end
    draft = file || files_array[choice.to_i][1]
    now = Date.today.strftime("%Y-%m-%d").gsub(/-0/,'-')
    mv draft, "_posts/#{now}-#{File.basename(draft)}"
    say_status("publish", "#{draft}", :green)
  end
  
  desc "posts", "list all posts"
  def posts
    print_table(Dir["_posts/*"].map { |p| [p] })
  end
end