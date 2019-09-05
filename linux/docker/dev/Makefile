UBUNTU=disco
BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
VERSION=$(shell date -u +'%Y.%m.%d')-$(UBUNTU)

.PHONY: build
build:
	docker build . \
		--build-arg UBUNTU=$(UBUNTU) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VERSION=$(VERSION) \
		-t sfiera/dev:latest \
		-t sfiera/dev:$(VERSION)
