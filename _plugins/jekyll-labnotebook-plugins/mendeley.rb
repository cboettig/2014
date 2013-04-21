## File: mendeley.rb
## Author: Michal Bus, github:@michalboo. Adapted by Carl Boettiger
## Date: 2013-04-18 
## Repository: https://github.com/michalboo/mendeley-oapi/blob/master/authorise.rb
## 
## Details: A complete implementation of the mendeley API as a collection of script modules
## Could probably be adapted into a gem quite easily. Meanwhile, I've modified this to be
## A single file for simplicity. At the very end, I've written the plugin to use these methods
## to include the most recent reading of a user by category (collection / folder).  


require 'rubygems'
require 'yaml'
require 'json'
require 'uri'
require 'oauth'
require 'digest/sha1'
require 'net/http'
require 'date'
require 'watir-webdriver'

class Mendeley
 
  #### Public Methods ######################################
  module Public_methods

    # stats methods
        
    def top_authors(discipline=nil, upandcoming=nil)
        options = Hash.new
        options[:discipline] = discipline if discipline
        options[:upandcoming] = upandcoming if upandcoming
        method_url = "/oapi/stats/authors/"
        response = get_response(method_url, options)
    end

    def top_papers(discipline=nil, upandcoming=nil)
      options = Hash.new
      options[:discipline] = discipline if discipline
      options[:upandcoming] = upandcoming if upandcoming
      method_url = "/oapi/stats/papers/"
      response = get_response(method_url, options)
    end

    def top_publications(discipline=nil, upandcoming=nil)
      options = Hash.new
      options[:discipline] = discipline if discipline
      options[:upandcoming] = upandcoming if upandcoming
      method_url = "/oapi/stats/publications/"
      response = get_response(method_url, options)
    end

    def top_tags(discipline)
      method_url = "/oapi/stats/tags/#{discipline}/"
      puts method_url
      response = get_response(method_url)
    end

    # catalog methods

    # @param [String] terms - search terms
    def document_search(term, page=nil, items=nil)
      encoded_term = URI.encode(term)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      method_url = "/oapi/documents/search/#{encoded_term}/"
      response = get_response(method_url, options)
    end

    def document_details(id, type=nil)
      options = Hash.new
      options[:type] = type if type
      method_url = "/oapi/documents/details/#{id}/"
      response = get_response(method_url, options)
    end

    def related_documents(id, page=nil, items=nil)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      method_url = "/oapi/documents/related/#{id}/"
      response = get_response(method_url, options)
    end

    def authored_documents(term, page=nil, items=nil, year=nil)
      encoded_term = URI.encode(term)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      options[:year] = year if year
      method_url = "/oapi/documents/authored/#{encoded_term}/"
      response = get_response(method_url, options)
    end

    def tagged_documents(term, page=nil, items=nil, cat=nil, subcat=nil)
      encoded_term = URI.encode(term)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      options[:cat] = cat if cat
      options[:subcat] = subcat if subcat
      method_url = "/oapi/documents/tagged/#{encoded_term}/"
      response = get_response(method_url, options)
    end

    def categories()
      method_url = "/oapi/documents/categories/"
      response = get_response(method_url)
    end

    def subcategories(category_id)
      method_url = "/oapi/documents/subcategories/#{category_id}/"
      response = get_response(method_url)
    end

    # public group methods

    def groups(page=nil, items=nil, cat=nil)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      options[:cat] = cat if cat
      method_url = "/oapi/documents/groups/"
      response = get_response(method_url, options)
    end

    def group_details(id)
      method_url = "/oapi/documents/groups/#{id}/"
      response = get_response(method_url)
    end

    def group_papers(id, details=nil, page=nil, items=nil)
      options = Hash.new
      options[:details] = details if details
      options[:page] = page if page
      options[:items] = items if items
      method_url = "/oapi/documents/groups/#{id}/docs/"
      response = get_response(method_url, options)
    end

    def group_people(id)
      method_url = "/oapi/documents/groups/#{id}/people/"
      response = get_response(method_url)
    end
  end



  ## Private Methods ###########################################
  module Private_methods

  # stats methods

    def library_authors
      method_url = "/oapi/library/authors/"
      response = get_response(method_url)
    end

    def library_tags
      method_url = "/oapi/library/tags/"
      response = get_response(method_url)
    end

    def library_publications
      method_url = "/oapi/library/publications/"
      response = get_response(method_url)
    end

  # document methods

    def library_documents(page=nil, items=nil)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      method_url = "/oapi/library/"
      response = get_response(method_url, options)
    end

    def library_authored(page=nil, items=nil)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      method_url = "/oapi/library/documents/authored/"
      response = get_response(method_url, options)
    end

    def library_doc_details(id)
      method_url = "/oapi/library/documents/#{id}/"
      response = get_response(method_url)
    end

    def create_document(document_json)
      method_url = "/oapi/library/documents/"
      body = { :document => document_json }
      response = post_response(method_url, body)
    end

    def update_document(id, document_json)
      method_url = "/oapi/library/documents/#{id}/"
      body = { :document => document_json }
      response = post_response(method_url, body)
    end

    def upload_file(id, file_name)
      method_url = "/oapi/library/documents/#{id}/"
      file_body = IO.read(file_name)
      sha1_hash = Digest::SHA1.hexdigest(file_body)
      response = put_response(method_url, file_name, file_body, sha1_hash) 
    end

    def download_file(id, file_hash, group_id=nil)
      method_url = "/oapi/library/documents/#{id}/file/#{file_hash}/"
      method_url << "#{group_id}/" if group_id
      options = Hash.new
      options[:with_redirect] = true
      response = get_response(method_url, options)
    end

    def delete_document(id)
      method_url = "/oapi/library/documents/#{id}/"
      response = delete_response(method_url)
    end

  # folder methods

    def folders
      method_url = "/oapi/library/folders/"
      response = get_response(method_url)
    end

    def folder_documents(id, page=nil, items=nil)
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      method_url = "/oapi/library/folders/#{id}/"
      response = get_response(method_url, options)
    end

    def add_document_to_folder(folder_id, doc_id)
      method_url = "/oapi/library/folders/#{folder_id}/#{doc_id}/"
      response = post_response(method_url)
    end

    def delete_document_from_folder(folder_id, document_id)
      method_url = "/oapi/library/folders/#{folder_id}/#{document_id}/"
      response = delete_response(method_url)
    end

    def create_folder(folder_json)
      method_url = "/oapi/library/folders/"
      body = { :folder => folder_json }
      response = post_response(method_url, body)
    end

    def delete_folder(folder_id)
      method_url = "/oapi/library/folders/#{folder_id}/"
      response = delete_response(method_url)
    end

  # group methods

    def library_groups
      method_url = "/oapi/library/groups/"
      response = get_response(method_url)
    end

    def library_group_people(group_id)
      method_url = "/oapi/library/groups/#{group_id}/people/"
      response = get_response(method_url)
    end

    def group_documents(group_id, page=nil, items=nil)
      method_url = "/oapi/library/groups/#{group_id}/"
      options = Hash.new
      options[:page] = page if page
      options[:items] = items if items
      response = get_response(method_url, options)  
    end

    def group_doc_details(group_id, document_id)
      method_url = "/oapi/library/groups/#{group_id}/#{document_id}/"
      response = get_response(method_url)
    end

    def create_group_folder(group_id, folder_json)
      method_url = "/oapi/library/groups/#{group_id}/folders/"
      body = { :folder => folder_json }
      response = post_response(method_url, body)
    end

    def delete_group_folder(group_id, folder_id)
      method_url = "/oapi/library/groups/#{group_id}/folders/#{folder_id}/"
      response = delete_response(method_url)
    end

    def group_folders(group_id)
      method_url = "/oapi/library/groups/#{group_id}/folders/"
      response = get_response(method_url)
    end

    def group_folder_documents(group_id, folder_id)
      method_url = "/oapi/library/groups/#{group_id}/folders/#{folder_id}/"
      response = get_response(method_url)
    end

    def add_document_to_group_folder(group_id, folder_id, document_id)
      method_url = "/oapi/library/groups/#{group_id}/folders/#{folder_id}/#{document_id}/"
      response = post_response(method_url)
    end

    def delete_document_from_group_folder(group_id, folder_id, document_id)
      method_url = "/oapi/library/groups/#{group_id}/folders/#{folder_id}/#{document_id}/"
      response = delete_response(method_url)
    end

    def create_group(group_json)
      method_url = "/oapi/library/groups/"
      body = { :group => group_json }
      response = post_response(method_url, body)
    end

    def delete_group(group_id)
      method_url = "/oapi/library/groups/#{group_id}/"
      response = delete_response(method_url)
    end

    def leave_group(group_id)
      method_url = "/oapi/library/groups/#{group_id}/leave/"
      response = delete_response(method_url)
    end

    def unfollow_group(group_id)
      method_url = "/oapi/library/groups/#{group_id}/unfollow/"
      response = delete_response(method_url)
    end

    # profiles methods

    def contacts
      method_url = "/oapi/profiles/contacts/"
      response = get_response(method_url)
    end

    def add_contact(profile_id)
      method_url = "/oapi/profiles/contacts/#{profile_id}/"
      response = post_response(method_url)
    end

    def profile_information(profile_id="me", section=nil, subsection=nil)
      options = Hash.new
      options[:section] = section if section
      options[:subsection] = subsection if subsection
      method_url = "/oapi/profiles/info/#{profile_id}/"
      response  = get_response(method_url, options)
    end
  end


  ### Authorize ##############################################

  module Authorise
    def self.oapi_authorise(consumer_key, consumer_secret, site, username=nil, password=nil)

      @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {
        :site => site,
          :http_method => :get,
          :request_token_path => "/oauth/request_token/",
          :access_token_path => "/oauth/access_token/",
          :authorize_path => "/oauth/authorize"
          })

      @request_token = @consumer.get_request_token

      verifier = Authorise.get_verifier(username, password)

      puts "Converting request token into access token"
      @access_token=@request_token.get_access_token(:oauth_verifier => verifier)

      auth = {access_token: @access_token}

      File.open('/home/cboettig/.mendeley_auth.yaml', 'w') {|f| YAML.dump(auth, f)}

      puts "Done. The auth.yaml file should have all it needs"
      return @access_token
    end

    def self.get_verifier(username=nil, password=nil)
      if username && password
        verifier = Browser.login_get_verifier(username, password, @request_token.authorize_url)
      else     
        puts "Go there, doofus: "
        puts @request_token.authorize_url
        puts "Put the thing here: "
        verifier = gets.chomp
      end
    end 
  end



  ## Browser #####################################################
  require 'watir-webdriver'

  module Browser
    # Creates a browser instance, authenticates as the user (w/ username and password provided), gets verification code
    def self.login_get_verifier(username=nil, password=nil, authorize_url=nil)
      $browser = Watir::Browser.new
      #TODO Anything other than the happy path
      $browser.goto(authorize_url)
      $browser.text_field(:id => "login_email").set(username)
      $browser.text_field(:id => "login_password").set(password)
      $browser.button(:text => "Login").click
      $browser.button(:text => "Accept").click
      verifier = $browser.div(:class => "box").text
      $browser.close

      return verifier
    end
  end


  include Public_methods
  include Private_methods
  include Authorise
  include Browser

  config = YAML::load(File.open("/home/cboettig/.mendeley_config.yaml"))
  $default_key = config[:default_key]
  $default_secret = config[:default_secret]
  $default_site = config[:default_site]

  def initialize(username=nil, password=nil, consumer_key=$default_key, consumer_secret=$default_secret, site=$default_site)

    if File.exist?("/home/cboettig/.mendeley_auth.yaml") && ((username && password) == nil)
      auth_contents = YAML::load(File.open("/home/cboettig/.mendeley_auth.yaml"))
      $access_token = auth_contents[:access_token]
    end
    $access_token = Authorise.oapi_authorise(consumer_key, consumer_secret, site, username, password) if $access_token == nil
    puts $access_token
  end

  def get_response(method_url, options=nil)
    @token = $access_token
    req = create_request_url(method_url, options)
    puts "Sending get request to: #{req}"
    response = @token.get(req)
    if response.code == "302"
      #TODO properly handle the download redirections
      response = Net::HTTP.get(URI(response.header['location']))
    end
    return response
  end

  def post_response(method_url, body=nil)
    @token = $access_token    
    response = @token.post(method_url, body)
  end

  def put_response(method_url, name, body, sha1)
    @token = $access_token
    response = @token.put(method_url, body, { "sha1_hash" => sha1, "file_name" => name, "Content-Disposition" => "attachment; filename='#{name}'", "oauth_body_hash" => sha1})
  end

  def delete_response(method_url)
    @token = $access_token
    response = @token.delete(method_url)
  end

  def create_request_url(method_url, options=nil)
    req = String.new
    req << method_url
    if options
      n = 0
      options.each do |key, value|
        n == 0 ? req << "?" : req << "&"
        req << "#{key}=#{value}"
        n += 1
      end
    end
    return req
  end
end





## Mendeley Jekyll plugin for categories 
## Author: Carl Boettiger
## Date: 2013-04-19


module Jekyll
  class MendeleyCategoryFeed < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      input = text.split(/, */ )
      @category = input[0]
      @count = input[1]
      if input[1] == nil
        @count = 3
      end
    end
    def render(context)
      # Initialize a redcarpet markdown renderer to autolink urls
      # Could use octokit instead to get GFM
      out = "<ul>"
      
      for i in 0 ... @count.to_i
        out = out + "<li>" + 
        + "</li>"
      end
      out + "</ul>"
    end
  end
end

Liquid::Template.register_tag('mendeley_category_feed', Jekyll::TwitterFeed)



