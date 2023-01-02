# def find_tracks (args)
#   subdirs = Dir.glob("mygame/sounds/music/*")
#   args.state.tracks = []
#   subdirs.each do |d|
#     if File.directory?("mygame/sounds/music/#{d}")
#       files = Dir.glob("mygame/sounds/music/#{d}/*")
#       files.each do |f|
#         subdirs.push(f)
#       end
#     end
#   end
#   args.state.tracks
# end

def play_music (args, title)
  args.outputs.sounds << "mygame/sounds/music/#{title}.wav"
  args.state.now_playing = title
end

def play_random_track (args)
  i = rand args.state.tracks.length
  play_music args, args.state.tracks[i]
end
