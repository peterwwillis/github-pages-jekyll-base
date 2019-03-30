
# Make sure to copy envrc.sample to envrc and fill out the following entries:create a file called 'envrc' which contains the following 
#
#   PAGES_REPO_NWO=<username>/<reponame>
#   JEKYLL_GITHUB_TOKEN=<a github token with public repo scope>

.PHONY: clean

all: check-deps
	@echo "Run 'make docker' to build and run a Docker container to run 'jekyll serve' in."
	@echo ""
	@echo "Run 'make build' to build a local version of Ruby and build and run 'jekyll build'."
	@echo "Run 'make serve' to use that locally-built Ruby/Jekyll."
	@echo ""
	@echo "If you have problems, try removing the 'Gemfile.lock' file and trying again."

# Magic!
include $(shell /bin/sh -c '. `pwd`/envrc ; env > .envrc && echo .envrc')
export

generate: update-deps fail-if-gemfile-changed

build: check-deps generate jekyll-build

serve: check-deps generate jekyll-serve


clean:
	bundle exec jekyll clean

clean-all: clean-deps
	bundle exec jekyll clean

fail-if-gemfile-changed:
	DIFFOUT=$$(git diff Gemfile.lock) ; \
	if [ -n "$$DIFFOUT" ] ; then \
		echo -e "Gemfile.lock has changed! Please commit before running build.\n\n$$DIFFOUT" ; \
		exit 1 ; \
	fi

jekyll-build:
	bundle exec jekyll doctor -t && \
	bundle exec jekyll build -t

jekyll-serve:
	bundle exec jekyll doctor -t && \
	bundle exec jekyll serve -t

check-deps:
	@if [ ! -r envrc ] ; then \
		echo "" ; \
		echo "Error: please copy envrc.sample to envrc and edit it to match your settings." ; \
		echo "You'll also probably want to edit _config.yml" ; \
		echo "" ; \
		exit 1 ; \
	fi

# Run 'make SKIP_BUNDLE_UPDATE=1' to skip this step entirely.
# Run 'make BUNDLE_DEPLOYMENT=1' to use --deployment, which is kind of weird.
# 
# Read more about 'bundle install' weirdness at https://bundler.io/bundle_install.html
update-deps: update-ruby-rvm
	if [ -z "$$SKIP_BUNDLE_UPDATE" ] ; then \
		if [ ! -d ".bundle" ] ; then \
			if [ "x$$BUNDLE_DEPLOYMENT" = "x1" ] ; then \
				bundle install --jobs 4 --deployment ; \
			else \
				bundle install --jobs 4 --path vendor/bundle ; \
			fi ; \
		fi ; \
		bundle update --all ; \
	fi

# To use the latest gems we need a recent ruby. This will install it using rvm.
# If the system name that rvm detects is "unknown", will disable use of
# autolibs and compile from scratch.
update-ruby-rvm:
	if [ ! x"$$USE_RVM" = x"1" ] ; then exit 0 ; fi ; \
	set -x ; \
	if [ ! -r $(PWD)/.ruby-version ] ; then echo "ERROR: Need $(PWD)/.ruby-version" ; exit 1 ; fi ; \
	RUBY_WANT_VER=$$(cat $(PWD)/.ruby-version) ; \
	if ! which ruby >/dev/null || ! ruby -v | grep -F $$RUBY_WANT_VER ; then \
		if [ ! -d "rvm/rubies/ruby-$$RUBY_WANT_VER" ] ; then \
			echo "Upgrading ruby! Hold on to your butts..." ; \
			if [ ! -d "rvm.sh" ] ; then \
				curl -sSL https://get.rvm.io > rvm.sh ; \
			fi ; \
			chmod 755 rvm.sh && \
			./rvm.sh --path $(PWD)/rvm --ignore-dotfiles && \
			if ./rvm/bin/rvm info | grep -q -e "name:.*unknown" ; then \
				./rvm/bin/rvm autolibs disable ; \
			fi && \
			./rvm/bin/rvm install $$RUBY_WANT_VER && \
			"./rvm/rubies/ruby-$$RUBY_WANT_VER/bin/ruby" -v >/dev/null && \
			./rvm/bin/rvm cleanup all ; \
		fi ; \
	fi

clean-ruby-rvm:
	rm -rf rvm/

clean-deps:
	rm -rf vendor/ .bundle

docker.build:
	docker build -t my-github-pages:latest -f Dockerfile.alpine .

docker: docker.build
	docker run --rm -v "$(PWD)":/usr/src/app -p "4000:4000" my-github-pages:latest

