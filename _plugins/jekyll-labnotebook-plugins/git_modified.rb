# Title: git_mod.rb
# Author: Carl Boettiger, @cboettig
# Licence: MIT
# Description: A custom filter to return the date that git has for the page modification time 
# 
# REQUIREMENTS: Uses `path` variable set in the base_name.rb plugin
#
# Example use: 
#
# {{ post.path | prepend:'_posts/' | git_modified }}
# 

require 'git'
 
module Jekyll
  module GitModFilter
    def git_modified(input)
      puts "Getting date modified from git using git_mod.rb"
      g = Git.open("/home/cboettig/Documents/labnotebook")
      begin
        out = g.log(1).object(input).first.date
      rescue Exception => e # Keep going if we hit an exception, e.g. path is wrong
          out = Time.now 
      end
      out 
    end
  end
end
Liquid::Template.register_filter(Jekyll::GitModFilter)
