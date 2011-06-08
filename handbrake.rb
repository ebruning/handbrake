#!/usr/bin/ruby -wKU

OUTPUTFOLDER = "/home/ebruning/itunes/wmv/"

$movies = Dir.glob("*")
$start_time = Time.now
count = 1

def convert_name(name)
	return OUTPUTFOLDER + File.basename(name, File.extname(name)) + ".m4v"
end

def print_status
	puts ""
	puts "Conversion started: " + $start_time.to_s
	puts "Movies converted:   " + ($movies.count - 1).to_s
	puts "Time ellapsed:      " + get_elapsed_time.to_s
end

def get_elapsed_time()
	Time.now - $start_time
end

puts ""
$movies.each do |movie|
	if File.file?(movie) == true
		if File.exists?(convert_name(movie)) == false
			puts "[%02d/%02d] Converting %s => %s" % [ count, $movies.count - 1, movie, convert_name(movie) ]
			system("HandBrakeCLI -i " + movie + " -o " + convert_name(movie) + " --preset \"AppleTV 2\" >/dev/null 2>&1")
			count = count + 1
		else
			puts movie + " already exists"
		end
	else
		#puts movie + " is not a movie (directory?)"
	end
end

print_status()
