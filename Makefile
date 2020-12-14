ENV ?= minikube
REGION ?= eu-west-1
FLUENTD_CHART = cnid/fluentd
RELEASE_NAME ?= logging
HELM_ARGS ?= --install --wait --dry-run --debug
CHART_VERSION ?= 2.2.2

# If you want to test a new version of the chart safely in a
# dev environment first, do something like:
#
# ifeq ("$(ENV)", "global-tools-dev")
#	CHART_VERSION = 2.0.6
# endif


all:
	$(MAKE) install

install:
	@helm upgrade $(RELEASE_NAME) $(FLUENTD_CHART) \
		$(HELM_ARGS) --timeout 1200s \
		--namespace logging \
		-f defaults.yaml -f $(REGION)/$(ENV).yaml \
		--set logstash_prefix=$(ENV)-$(REGION)- \
		--version $(CHART_VERSION)
