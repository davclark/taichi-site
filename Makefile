serve: index.html elm test
	bundle exec jekyll serve

elm: video.elm
	elm-make video.elm --output=video.js

test: test.elm
	elm-make test.elm --output=test.html
