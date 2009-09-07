#!/usr/bin/env ruby

require "rexml/document"
require "fileutils"
require "yaml"
include REXML
INKSCAPE = '/usr/bin/inkscape'
SRC = "moblin-icon-theme.svg"
PREFIX = "moblin/24x24"
LAUNCHER_PREFIX = "moblin/48x48"
COLORS = YAML::load(File.open("group-colors.yml"))
EMBLEM = "temp/emblem"
TEMPLATE = "template.svg"

def renderIcon(icon)
	unless (File.exists?("#{LAUNCHER_PREFIX}/#{icon[:context]}/#{icon[:name]}.png") && !icon[:forcerender])
		puts "rendering #{icon[:name]}"
		#recolor strokes and fills that are grey (#bebebe) to white
		emblem = File.new("#{EMBLEM}.svg", "w")
		File.open(icon[:file]) do |line|
			emblem.puts line.read.gsub(/#bebebe/, "#ffffff/gi")
		end
		emblem.close
		cmd = "#{INKSCAPE} -e #{EMBLEM}.png #{EMBLEM}.svg > /dev/null 2>&1"
		system cmd
		
		#recolor template based on group colors
		$template.root.elements["//rect[@inkscape:label='group-color']"].attributes['style'] = "fill:#{COLORS[icon[:group]]};fill-opacity:1"
		base = File.new("temp/base.svg","w")
		base.puts $template
		base.close
		cmd = "#{INKSCAPE} -e temp/base.png temp/base.svg > /dev/null 2>&1"
		system cmd
		
		#overlay
		#composite above.png -compose Over -gravity center under.png result.png
		FileUtils.mkdir_p("#{LAUNCHER_PREFIX}/#{icon[:context]}") unless File.exists?("#{LAUNCHER_PREFIX}/#{icon[:context]}")
		cmd = "composite #{EMBLEM}.png -compose Over -gravity center temp/base.png #{LAUNCHER_PREFIX}/#{icon[:context]}/#{icon[:name]}.png"
		system cmd
	else
		puts " -- #{icon[:name]} already exists"
	end
end

#main
FileUtils.mkdir_p("moblin") unless File.exists?("moblin")
# Open SVG file and template.
svg = Document.new(File.new(SRC, 'r'))
$template = Document.new(File.new(TEMPLATE, 'r'))

if (ARGV[0].nil?) #render all SVGs
  puts "Rendering from icons in #{SRC}"
	# Go through every layer.
	svg.root.each_element("/svg/g[@inkscape:groupmode='layer']") do |context| 
		context_name = context.attributes.get_attribute("inkscape:label").value  
#		puts "Going through layer '" + type_name + "'"
		if (context_name.match(/app/)) 
			context.each_element("g") do |icon|
				dir = "#{PREFIX}/#{context_name}"
				icon_name = icon.attributes.get_attribute("inkscape:label").value
				group = icon.elements["title"].nil? ? "default" : icon.elements["title"].text
				renderIcon({	:name => icon_name,
				 					:id => icon.attributes["id"],
				 					:dir => dir,
				 					:group => group,
				 					:context => context_name,
				 					:file => "#{dir}/#{icon_name}.svg"})
			end
		end
	end
  puts "\nrendered all SVGs"
else #only render the icons passed
  icons = ARGV
  ARGV.each do |icon_name|
  	icon = svg.root.elements["//g[@inkscape:label='#{icon_name}']"]
  	context = icon.parent.attributes['inkscape:label']
  	dir = "#{PREFIX}/#{context}"
  	group = icon.elements["title"].nil? ? "default" : icon.elements["title"].text 
		renderIcon({	:name => icon_name,
		 					:id => icon.attributes["id"],
		 					:dir => dir,
		 					:file => "#{dir}/#{icon_name}.svg",
  	 					:group => group,
  	 					:context => context,
		 					:forcerender => true})
	end
  puts "\nrendered #{ARGV.length} icons"
end
