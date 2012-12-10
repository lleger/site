require 'jekyll_asset_pipeline'

# module JekyllAssetPipeline
#   class CoffeeScriptConverter < JekyllAssetPipeline::Converter
#     require 'coffee-script'
# 
#     def self.filetype
#       '.coffee'
#     end
# 
#     def convert
#       return CoffeeScript.compile(@content)
#     end
#   end
# end

module JekyllAssetPipeline
  class SassConverter < JekyllAssetPipeline::Converter
    require 'sass'

    def self.filetype
      '.scss'
    end

    def convert
      begin
        sass = Sass::Engine.new(@content, syntax: :scss).render
      rescue Exception => e
        p "FAIL"
        p e
      end
      return sass
      # p @content
      # sass = Sass::Engine.new(@content, syntax: :scss).render
      # p sass.to_s
      # return sass
    end
  end
end

# module JekyllAssetPipeline
#   class CssCompressor < JekyllAssetPipeline::Compressor
#     require 'yui/compressor'
# 
#     def self.filetype
#       '.css'
#     end
# 
#     def compress
#       return YUI::CssCompressor.new.compress(@content)
#     end
#   end
# 
#   class JavaScriptCompressor < JekyllAssetPipeline::Compressor
#     require 'yui/compressor'
# 
#     def self.filetype
#       '.js'
#     end
# 
#     def compress
#       return YUI::JavaScriptCompressor.new(munge: true).compress(@content)
#     end
#   end
# end