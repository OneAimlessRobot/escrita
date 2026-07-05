#!/bin/bash
# 1. Install ImageMagick
#sudo apt update
#sudo apt install imagemagick

# 2. Use it to convert in.webp to other file types
#convert in.webp out.png
#convert in.webp out.jpg
#convert in.webp out.bmp
#convert in.webp out.tiff
# or .png to other types
#convert out.png out.jpg
# ...
#

raw_image_folder_name="raw"

the_raw_image_dir="$(pwd)/${raw_image_folder_name}"

the_raw_image_extension="jpg"

destination_folder_name=""

pattern="*"

the_destination_dir="$(pwd)/${the_destination_folder_name}"

the_destination_image_extension="png"



command_for_names="$(find ${the_raw_image_dir} -name ${pattern}.${the_raw_image_extension} -exec basename -s .${the_raw_image_extension} {} \;)"

total=0

array_of_names=()


insert_raw_songs_loop_function(){

	for the_file in $command_for_names
	do
		array_of_names[total]="${the_file}"
		((total++))
	done
}


print_raw_songs_loop_function(){

	for(( i=0; i< num_of_images; i++ ))
	do
		echo "${the_raw_image_dir}/${array_of_names[$i]}.${the_raw_image_extension}"
	done
}

conversion_loop_function(){

	for(( i=0; i< num_of_images; i++ ))
	do
		convert "${the_raw_image_dir}/${array_of_names[$i]}.${the_raw_image_extension}" "${the_destination_dir}/${array_of_names[$i]}.${the_destination_image_extension}"
	done
}

insert_raw_songs_loop_function
num_of_images=${#array_of_names[@]}

print_raw_songs_loop_function

conversion_loop_function


