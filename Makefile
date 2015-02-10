## be sure to do `source ../.notebook-env.sh` fist
## Cannot run this in makefile since it doesn't understand 'source'
## Cannot run with bash -c "source ../.notebook-env.sh" since then it's not available to the parent shell
all:
	make build
	make deploy

build:
	docker run \
		-v $(PWD):/data \
		-w /data --rm \
		cboettig/labnotebook Rscript -e "servr::jekyll(serve=FALSE, script='build.R')"

deploy:
	./deploy.sh	

