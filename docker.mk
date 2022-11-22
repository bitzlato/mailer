VERSION ?= latest
REPO=mailer
REGISTRY=nexus.lgk.one
IMAGE_NAME=${REGISTRY}/${REPO}:${VERSION}

docker-release: docker-build docker-push
docker-build: check-args
	docker build -t ${IMAGE_NAME} .
docker-push: check-args
	docker push ${IMAGE_NAME}
check-args:
ifndef VERSION
	$(error VERSION is undefined)
endif
