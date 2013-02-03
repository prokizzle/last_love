require 'rubygems'
require 'lastfm'
require 'launchy'
require 'appscript'
# itunes = Appscript.app.by_name("iTunes")
# puts itunes.current_tracK

class LastLove

  def initialize(api_key, api_secret)
    @account_valid = true
    @lastfm = Lastfm.new(api_key, api_secret)
    self.authenticate
  end

  def authenticate
    begin
      File.open("session_key.txt", 'r') do |f|
        @lastfm.session = f.read
      end
    rescue
      self.create_new_session
    end
  end

  def create_new_session
    begin
      token = @lastfm.auth.get_token
      puts "Authorizing on LastFM",""
      puts "Launching last.fm. Please login and grant access."
      Launchy.open "http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}"
      # puts "Waiting..."
      print "Ready? "
      response = gets.chomp
      @lastfm.session = @lastfm.auth.get_session(:token => token)['key']
      File.open("session_key.txt", 'w') do |f|
        f.write(@lastfm.session)
      end
    rescue Exception => e
      puts e.message
      @account_valid = false
    end
end

  def account_valid
    @account_valid
  end

  def scrobble
    @lastfm.track.scrobble(:artist => track_artist, :track => track_name)
  end

  def track_artist
    %x{osascript <<'APPLESCRIPT'
       tell application "iTunes"
       set track_artist to artist of current track
       end tell
       return track_artist
       APPLESCRIPT
       }
  end


  def track_name
    %x{osascript <<'APPLESCRIPT'
       tell application "iTunes"
       set track_name to name of current track
       end tell
       return track_name
       APPLESCRIPT
       }
  end

  def love
    @lastfm.track.love(:artist => track_artist, :track => track_name)
  end

  def update_now_playing
    @lastfm.track.update_now_playing(:artist => track_artist, :track => track_name)
  end

  def run
    self.love if account_valid
  end

end