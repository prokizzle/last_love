require 'lastfm'
require 'launchy'

api_key = "b7504d75a130985d48183fb37f0536a9"
api_secret = "bd50f784539cc8cd698185aeeb1c2400"
session= "62999652a9386ed0c9d00ba83c8fe7da"

lastfm = Lastfm.new(api_key, api_secret)

# puts "Authorizing"
begin
File.open("session_key.txt", 'r') do |f|
    lastfm.session = f.read
    puts lastfm.session
end
rescue Exception => e
    puts "Authorizing on LastFM",""
    puts "Launching last.fm. Please login and grant access."
    puts e
    token = lastfm.auth.get_token
    Launchy.open "http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}"
    # puts "Waiting..."
    print "Ready? "
    response = gets.chomp
    lastfm.session = lastfm.auth.get_session(:token => token)['key']
    File.open("session_key.txt", 'w') do |f|
        f.write(lastfm.session)
    end
end


# lastfm.track.love(:artist => 'Hujiko Pro', :track => 'acid acid 7riddim')
# lastfm.track.scrobble(:artist => artist, :track => track)

track_artist = %x{osascript <<'APPLESCRIPT'
    tell application "iTunes"
        set track_artist to artist of current track
    end tell

    return track_artist
    APPLESCRIPT
}

track_name = %x{osascript <<'APPLESCRIPT'
    tell application "iTunes"
        set track_name to name of current track
    end tell


    return track_name
    APPLESCRIPT
}

lastfm.track.love(:artist => track_artist, :track => track_name)
# lastfm.track.update_now_playing(:artist => "Hujiko Pro", :track => "acid acid 7riddim")