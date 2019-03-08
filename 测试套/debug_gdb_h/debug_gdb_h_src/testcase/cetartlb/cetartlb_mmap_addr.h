
//hert              test size is 0x1000000   16M
#ifdef HERT
#define ADDR 0x80000000
#define ADDR2  0x81000000
#define ADDR_ABNORMAL 0xc0000000   //kernel addr
#else
#ifdef HI1381
#define ADDR 0x80000000
#define ADDR2  0x81000000
#define ADDR_ABNORMAL 0xc0000000   //kernel addr
#else
//ggsn  mbsc         test size is 0x40000000   1G
#define ADDR 0x40000000
#define ADDR2 0x80000000
#define ADDR_ABNORMAL 0x860000000   //kernel addr
#endif
#endif
