serve: index.html elm
	bundle exec jekyll serve

jekyll-build: index.html
	bundle exec jekyll build

build: index.html elm
	bundle exec jekyll build

elm: video.js video-late-2016.js

video.js: video.elm MyViews.elm
	elm-make video.elm --output=video.js

video-late-2016.js: video-late-2016.elm  MyViews.elm
	elm-make video-late-2016.elm --output=video-late-2016.js
