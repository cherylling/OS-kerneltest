#RTOS version does not open suspend option in kernel config, so skip it.

MODULES=sys_perf_event_open modules perf

default:
	for i in ${MODULES};do make -C $$i;done

install:
	for i in ${MODULES};do make -C $$i install;done

clean:
	for i in ${MODULES};do make -C $$i clean;done
