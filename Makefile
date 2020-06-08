SEVERITIES = HIGH,CRITICAL

ifeq ($(TAG),)
TAG=dev
endif

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) ARCH=$(ARCH) -t ranchertest/goboring:$(TAG)-$(ARCH) .

.PHONY: image-push
image-push:
	docker push ranchertest/goboring:$(TAG)-$(ARCH) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed ranchertest/goboring:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	docker image inspect ranchertest/goboring:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create briandowns/goboring:$(TAG)-$(ARCH) \
		$(shell docker image inspect ranchertest/goboring:$(TAG)-$(ARCH) | jq -r '.[] | .RepoDigests[0]')
