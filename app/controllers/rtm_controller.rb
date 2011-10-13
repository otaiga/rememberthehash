class RtmController < ApplicationController


  require 'httparty'
  require 'digest/md5'
  require 'open-uri'
  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'rexml/document'

  FROB = "3dfa45ab1f725f2fef1f83ac545c0f504c8e54dc"
  TOKEN ="95c563711e0bd8762c43b08389bfc6c6f458e3c1"

  include REXML

    RTMKEY = ENV['RTMKEY']
    RTMSECRET = ENV['RTMSECRET']

    AUTHURL = 'http://www.rememberthemilk.com/services/auth/'
    RTMURL = 'http://www.rememberthemilk.com/services/rest/'
    FROBURL ='https://api.rememberthemilk.com/services/rest/'
    TASKURL = 'http://www.rememberthemilk.com/services/rest/?method=rtm.tasks.add'

    def main
    end


    def frob
      method = "methodrtm.auth.getFrob"
      api_sig = RTMSECRET + "api_key" + RTMKEY + method
      api_fin = Digest::MD5.hexdigest(api_sig)

      path = FROBURL+"?method=rtm.auth.getFrob&api_key="+ RTMKEY + "&api_sig=#{api_fin}" 
      puts path
      res = open(path) {|http| http.readlines}
      puts res

    end


    #this does not work: auth
    def auth
      api_sig = RTMSECRET + "api_key" + RTMKEY + "permsdelete"
      puts api_sig
      api_fin = Digest::MD5.hexdigest(api_sig)
      puts api_fin

      redirect_to AUTHURL + "?&api_key=#{RTMKEY}&perms=delete&api_sig=#{api_fin}"
    #Need to add this to the FROB value
    end



    def get_token
      method = 'methodrtm.auth.getToken'
      api_sig = RTMSECRET + "api_key" + RTMKEY + "frob" + FROB + method
      api_fin = Digest::MD5.hexdigest(api_sig)
      path = RTMURL + "?method=rtm.auth.getToken&api_key=#{RTMKEY}&frob=#{FROB}&api_sig=#{api_fin}"
      data = open(path) {|http| http.read}
      puts data

    end



    def create_task   
          task = "taska"
          token = TOKEN
          url = "http://www.rememberthemilk.com/services/rest/?method=rtm.tasks.add"
          timeline ="timeline10021"
          tokenkey = "auth_token#{TOKEN}"
          name = "name#{task}"
          method = "methodrtm.tasks.add"
          api_sig_before = RTMSECRET + "api_key" + RTMKEY + tokenkey + method + name + timeline 
          api_sig = Digest::MD5.hexdigest(api_sig_before)
  		    path = TASKURL + "&api_key=#{RTMKEY}" + "&name=#{task}" + "&timeline=10021" + "&auth_token=#{TOKEN}" +"&api_sig=#{api_sig}"
          open(URI.encode(path)) {|http| http.read} #Encode to send task with titles
          redirect_to "/pages/main"


    end

  end

