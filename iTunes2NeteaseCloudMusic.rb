require 'plist'

# 方法来自http://hktkdy.com/2016/08/09/201608/spotify-to-easenet/
# 需要安装 plist
# <?xml version="1.0" encoding="windows-1252"?>
# <List ListName="默认列表">
# <FileName>邓紫棋 - 泡沫.mp3</FileName>
# <FileName>筷子兄弟 - 小苹果.mp3</FileName>


if ARGV.length != 1
  puts '使用说明：'
  puts 'iTunes2NeteaseCloudMusic.exe "iTunes 库文件iTunes Music Library.xml的绝对路径"'
  exit
end
filename = ARGV[0]
unless File.exist?(filename)
  puts "iTunes 库文件#{filename} 不存在，请检查"
  exit
end

begin
  result = Plist::parse_xml(File.read(filename).force_encoding('utf-8'))
  puts "资料库文件应用版本为#{result['Application Version']}"
rescue Exception =>e
  puts  "文件名#{filename}无法正确解析，请确认是Windows版iTunes资料库文件"
end
# 播放列表在资料库级别
result['Playlists'].select{|e| e['Playlist Items'] != nil}.each do |playlist|
  #把playlist的数据导入到文件中
  begin
    output_filename = "#{playlist['Name']}.kgl"
    out = File.open(output_filename, 'w')
    out.puts('<?xml version="1.0" encoding="windows-1252"?>')
    out.puts("<List ListName=\"#{playlist['Name']}\">")
    playlist['Playlist Items'].each do |item|
      track_id = item['Track ID'].to_s
      track = result['Tracks'][track_id]
      data = "<![CDATA[#{track['Artist']} - #{track['Name']}.mp3]]>"
      out.puts("<FileName>#{data}</FileName>")
    end
  rescue Exception => e
    puts e
    next
  end
end


