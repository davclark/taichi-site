serve: index.html elm
	bundle exec jekyll serve

elm: video.elm
	elm-make video.elm --output=video.js
