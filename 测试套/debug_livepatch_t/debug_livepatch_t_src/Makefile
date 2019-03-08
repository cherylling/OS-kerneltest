#RTOS version does not open suspend option in kernel config, so skip it.

THIS_MODULE_PATH=$(shell pwd)
LIVEPATCH_TESTCASES_DIR=$(THIS_MODULE_PATH)/livepatch-autotest-testcases
LIVEPATCH_TESTS_CONF=${KERNEL_TEST_ROOT}/tests/debug_livepatch_t

default:
	wget http://code.huawei.com/livepatch/livepatch-autotest/raw/master/livepatch-autotest-global.sh?download_type=raw \
		-O livepatch-autotest-global.sh
	wget http://code.huawei.com/livepatch/livepatch-autotest/raw/master/livepatch-autotest-gen-testcases.sh?download_type=raw \
		-O livepatch-autotest-gen-testcases.sh
	bash ./livepatch-autotest-global.sh --arch=$(ARCH) 	\
		--compile=$(CROSS_COMPILE)			\
		--kernel=$(KERNEL_DIR)				\
		--output=$(TOOL_BIN_DIR)			\
		--todo=build

	bash ./livepatch-autotest-gen-testcases.sh $(LIVEPATCH_TESTCASES_DIR) $(LIVEPATCH_TESTS_CONF)

install:

clean:
	bash ./livepatch-autotest-global.sh --arch=$(ARCH) 	\
		--compile=$(CROSS_COMPILE)			\
		--kernel=$(KERNEL_DIR)				\
		--output=$(TOOL_BIN_DIR)			\
		--todo=clean
