class HashblueController < ApplicationController
    require 'open-uri'
    require 'json'
    require 'httparty'
    require 'hash-blue'


    CLIENT_ID = ENV['HBCLIENT_ID']
    CLIENT_SECRET = ENV['HBCLIENT_SECRET']
    AUTH_SERVER = "https://hashblue.com"
    API_SERVER = "https://api.hashblue.com"

    def main

      if session[:access_token]
         # authorized so request the messages from #blue)
         @messages_response = get_with_access_token("/messages.json")
         case @messages_response.code
        when 200
           @messages = @messages_response["messages"]
              @messages.reverse.each {|message| puts message}
           
                  when 401
                   redirect_to AUTH_SERVER + "/oauth/authorize?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&redirect_uri=http://" + request.host_with_port + "/callback"
                  else
                    "Got an error from the server (#{@messages_response.code.inspect}): #{CGI.escapeHTML(@messages_response.inspect)}"
                  end
                else
                  # No Access token therefore authorize this application and request an access token
                  redirect_to "https://hashblue.com/oauth/authorize?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&redirect_uri=http://" + request.host_with_port + "/callback"
                  puts "ERROR TOKEN #{CLIENT_SECRET}"
                 end
              end
              
    
      def callback
          # assuming access is granted
          # Call server to get an access token
          response = HTTParty.post(AUTH_SERVER + "/oauth/access_token", :body => {
            :client_id => CLIENT_ID,
            :client_secret => CLIENT_SECRET,
            :redirect_uri => "http://" + request.host_with_port + "/callback",
            :code => params["code"],
            :grant_type => 'authorization_code'}
          )

          session[:access_token] = response["access_token"]
          $access_token = response["access_token"]
          HashBlue::Client.user = $access_token    
          redirect_to '/pages/main'
         end
         
         
         
         def get_with_access_token(path)
            HTTParty.get(API_SERVER + path, :query => {:oauth_token => access_token, :since => "2011-09-29T23:00Z" })
          end
          
          def access_token
            session[:access_token]
          end
          
          
          
          def get_token_from_cookie

            cookie_token = request.cookies['token']
            cookie_token = cookie_token.split("|")
            if cookie_token.size != 2
                 raise SyntaxError, "The cookie is not valid"
               end     
             @request_token = cookie_token[0]
             @request_secret = cookie_token[1]

          end
          
  end
