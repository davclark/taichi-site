serve: index.html elm
	bundle exec jekyll serve

deploy: index.html
	bundle exec jekyll build --destination ../taichi.reallygoodmoving.com

build-all: index.html elm
	bundle exec jekyll build

elm: video.js video-late-2016.js extra-material.js

video.js: video.elm MyVideo.elm
	elm-make video.elm --output=video.js

extra-material.js: extra-material.elm MyVideo.elm
	elm-make extra-material.elm --output=extra-material.js

# Started to adapt this, then decided it's not worth doing...
# video-late-2016.js: video-late-2016.elm  MyViews.elm
# 	elm-make video-late-2016.elm --output=video-late-2016.js
