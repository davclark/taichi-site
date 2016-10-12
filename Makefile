serve: index.html elm-stuff
	bundle exec jekyll serve

elm-stuff: video.elm
	elm-make video.elm --output=video.js
