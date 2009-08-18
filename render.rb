#!/usr/bin/env ruby

require "rexml/document"
require "ftools"
include REXML
INKSCAPE = '/usr/bin/inkscape'
SRC = "moblin-icon-theme.svg"

def chopSVG(icon)
	File.makedirs(icon[:dir]) unless File.exists?(icon[:dir])
	unless File.exists?(icon[:file])
		File.copy(SRC,icon[:file]) 
		puts " >> #{icon[:name]}"
		cmd = "#{INKSCAPE} -f #{icon[:file]} --select #{icon[:id]} --verb=FitCanvasToSelection  --verb=EditInvert "
		cmd += "--verb=EditDelete --verb=EditSelectAll --verb=SelectionUnGroup --verb=StrokeToPath "
		cmd += "--verb=FileSave --verb=FileClose > /dev/null 2>&1"
		system(cmd)
	else
		puts " -- #{icon[:name]} already exists"
	end
end

def renderit(icons)

  

	
	

end # End of function.


File.makedirs("moblin") unless File.exists?("moblin")
# Open SVG file.
svg = Document.new(File.new(SRC, 'r'))

if (ARGV[0].nil?) #render all SVGs
  puts "Rendering from icons in #{SRC}"
	# Go through every layer.
	svg.root.each_element("/svg/g[@inkscape:groupmode='layer']") do |context| 
		context_name = context.attributes.get_attribute("inkscape:label").value  
#		puts "Going through layer '" + type_name + "'"
		context.each_element("g") do |icon|
			dir = "moblin/24x24/#{context_name}"
			icon_name = icon.attributes.get_attribute("inkscape:label").value
			chopSVG({	:name => icon_name,
			 					:id => icon.attributes.get_attribute("id"),
			 					:dir => dir,
			 					:file => "#{dir}/#{icon_name}.svg"})
		end
	end
  puts "\nrendered all SVGs"
else #only render the SVG passed
  icons = ARGV
  ARGV.each do |icon|
  	puts icon
	end
  puts "\nrendered #{ARGV.length} icons"
end
