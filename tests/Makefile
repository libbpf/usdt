# SPDX-License-Identifier: BSD-2-Clause
AWK ?= awk
READELF ?= readelf
BPFTRACE ?= bpftrace
OUTPUT ?= .output

export AWK READELF BPFTRACE

ifeq ($(V),1)
	Q =
	msg =
else
	Q = @
	msg = @printf '  %-8s %s\n'					\
		      "$(1)"						\
		      "$(patsubst $(OUTPUT)/%,%,$(2))"
	MAKEFLAGS += --no-print-directory
endif

ifeq ($(OUTPUT),)
$(error OUTPUT variable cannot be empty)
endif

NONTESTS = tester common

TESTS_C := $(filter-out $(NONTESTS),$(shell ls *.c 2>/dev/null | ${AWK} '{split($$0, parts, /[^A-Za-z_]+/); print parts[1]}' | sort | uniq))
TESTS_CXX := $(filter-out $(NONTESTS),$(shell ls *.cpp 2>/dev/null | ${AWK} '{split($$0, parts, /[^A-Za-z_]+/); print parts[1]}' | sort | uniq))

# Derive the corresponding targets from the list
BUILD_TARGETS = $(TESTS_C:%=build-%) $(TESTS_CXX:%=build-%)
TEST_TARGETS = $(TESTS_C:%=test-%) $(TESTS_CXX:%=test-%)

.PHONY: all
all: $(BUILD_TARGETS)
	$(info ALL DEPS: $^)

.PHONY: clean
clean:
	$(call msg,CLEAN)
	$(Q)rm -rf $(OUTPUT)

.PHONY: list-tests
list-tests:
	$(Q)$(foreach test,$(TESTS_C) $(TESTS_CXX), $(info $(test)))

.PHONY: build
build: $(BUILD_TARGETS)

.PHONY: test
test: $(TEST_TARGETS)

$(OUTPUT):
	$(Q)mkdir -p $(OUTPUT)

define C_BUILD_RULE
$$(OUTPUT)/$(1): $$(wildcard $(1)*.[ch]) common.c common.h | $$(OUTPUT)
	$$(call msg,CC,$$@)
	$$(Q)$$(CC) $$(CFLAGS) -g $$(filter %.c, $$^) -o $$@
endef

# Define build rule for each C test
$(foreach test, $(TESTS_C), $(eval $(call C_BUILD_RULE,$(test))))

define CXX_BUILD_RULE
$$(OUTPUT)/$(1): $$(wildcard $(1)*.cpp $(1)*.h) common.c common.h | $$(OUTPUT)
	$$(call msg,CXX,$$@)
	$$(Q)$$(CXX) $$(CXXFLAGS) -g $$(filter %.cpp %.c, $$^) -o $$@
endef

# Define build rule for each C++ test
$(foreach test, $(TESTS_CXX), $(eval $(call CXX_BUILD_RULE,$(test))))

$(BUILD_TARGETS): build-%: $(OUTPUT)/%

$(TEST_TARGETS): test-%: build-%
	$(call msg,TESTING,$(patsubst test-%,%,$@))
	$(Q)./run_test.sh $(OUTPUT)/$(patsubst test-%,%,$@)
	$(call msg,TESTING,$(patsubst test-%,%,$@))
