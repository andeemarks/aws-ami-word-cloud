require 'aws-sdk'

def in_stoplist(word)
  ["image", "ec", "images", "ami"].include?(word)
end

def tokenize(image_name)
  image_name.downcase.delete("0-9\.").split(/[-_\/]/) 
end

def process_image(output, image, index, ami_in_region)
  image_name = image.name
  if !image_name.nil?
    ami_in_region = ami_in_region + 1
    words = tokenize(image_name)
    words.reject! {|word|
      in_stoplist(word) || word.length <= 1
    }
    output.puts words
  end

  ami_in_region
end

def process_images_for_region(region, region_images)
  puts "Looking for ami in #{region.name}... "
  File.open("#{region.name}_ami_words.txt", "w") do |output|
    ami_in_region = 0
    region_images.each_with_index {|image, index|
      ami_in_region = process_image(output, image, index, ami_in_region)
    }
    puts "Found #{ami_in_region.to_s} ami in #{region.name}"
  end
end

ec2 = AWS::EC2.new(
    :access_key_id => '[INSERT_ACCESS_KEY_HERE]',
    :secret_access_key => '[INSERT_SECREY_ACCESS_KEY_HERE]]')

ec2.regions.each {|region|
  region_images = ec2.regions[region.name].images
  process_images_for_region(region, region_images)
}