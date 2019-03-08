default:
	cp hostconf.in hostconf 

install:
	mkdir -p ${TOOL_BIN_DIR}/../../conf
	cp get_FS_TESTDIR.sh expectconf.in fill_data.sh hostconf performance_format.xml pre_getmemsize.sh \
		send_command.exp testconf ${TOOL_BIN_DIR}/../../conf

clean:
	rm -f expectconf performance_result.xls hostconf expectconf
