jekyll-build: index.html
	bundle exec jekyll build

build: index.html elm
	bundle exec jekyll build

serve: index.html elm
	bundle exec jekyll serve

elm: video.elm
	elm-make video.elm --output=video.js
