
.PHONY: clean watch

compiled.css: css/*.css
	cat css/normalize.css css/typebase.css css/fonts.css css/app.css > compiled.css

clean:
	rm -f compiled.css

watch:
	make
	@fswatch -o0 css/ | xargs -0 -n1 -I{} make