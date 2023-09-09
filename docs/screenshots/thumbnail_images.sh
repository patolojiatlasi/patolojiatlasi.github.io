# https://chat.openai.com/share/8528715b-e52b-425e-a5d0-01f3da5380d5

# imagemagick

# brew install imagemagick
# for file in *.png; do convert "$file" "${file%.png}.jpg"; done

# vips
# brew install vips
for file in ./screenshots/*.png; do vips copy "$file" "${file%.png}.jpg"; done

