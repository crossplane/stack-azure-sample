PACKAGE_VERSION ?= local
PACKAGE_IMG ?= crossplane/stack-azure-sample:$(PACKAGE_VERSION)

build:
	docker build . -t ${PACKAGE_IMG}
.PHONY: build

publish:
	docker push ${PACKAGE_IMG}
.PHONY: publish
