SEVERITIES = HIGH,CRITICAL

ifeq ($(TAG),)
TAG=dev
endif

ifeq ($(ARCH),)
ARCH=arm64
endif


.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) --build-arg ARCH=$(ARCH) -t briandowns/goboring:$(TAG)-$(ARCH) .

.PHONY: image-push
image-push:
	docker push briandowns/goboring:$(TAG)-$(ARCH) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed briandowns/goboring:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	#docker image inspect briandowns/goboring:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create briandowns/goboring:$(TAG)-$(ARCH) \
		$(shell docker image inspect briandowns/goboring:$(TAG)-$(ARCH) | jq -r '.[] | .RepoDigests[0]')
	#DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push 
