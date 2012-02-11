require 'fileutils'

def confirm?
  puts "File exists, replace?"
  gets.chomp == 'y' ? true : false
end

user_dir = '/media/Windows7_OS/Users/Fletch'
backup_dir = '/home/fletch/Dropbox/backups/game_saves'

save_dirs = {
  'Prototype' => "#{user_dir}/Documents/Prototype"
}

save_dirs.each do |title, path|
  backup_path = File.join(backup_dir, title)
  Dir.mkdir(backup_path) unless Dir.exists?(backup_path)
  files = Dir.glob(File.join(path, '*'))
  files.each do |file|
    file_name = file.split('/').last
    if File.exists?(File.join(backup_path, file_name))
      FileUtils.copy(file, backup_path) if confirm?
    else
      FileUtils.copy(file, backup_path)
    end
  end
end
