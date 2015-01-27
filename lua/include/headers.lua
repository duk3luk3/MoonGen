local ffi = require "ffi"

-- structs
ffi.cdef[[
	// TODO: vlan support (which can be offloaded to the NIC to simplify scripts)
	struct __attribute__ ((__packed__)) mac_address {
		uint8_t		uint8[6];
	};
	
	struct __attribute__((__packed__)) ethernet_header {
		struct mac_address	dst;
		struct mac_address	src;
		uint16_t		type;
	};

	union ipv4_address {
		uint8_t		uint8[4];
		uint32_t	uint32;
	};

	union ipv6_address {
		uint8_t 	uint8[16];
		uint32_t	uint32[4];
		uint64_t	uint64[2];
	};

	struct __attribute__((__packed__)) ipv4_header {
		uint8_t			verihl;
		uint8_t			tos;
		uint16_t		len;
		uint16_t		id;
		uint16_t		frag;
		uint8_t			ttl;
		uint8_t			protocol;
		uint16_t		cs;
		union ipv4_address	src;
		union ipv4_address	dst;
	 };

	struct __attribute__((__packed__)) ipv6_header {
		uint32_t 		vtf;
		uint16_t  		len;
		uint8_t   		nextHeader;
		uint8_t   		ttl;
		union ipv6_address 	src;
		union ipv6_address	dst;
	};

	struct __attribute__((__packed__)) udp_header {
		uint16_t 	src;
		uint16_t     	dst;
		uint16_t     	len;
		uint16_t     	cs;
	};

	struct __attribute__((__packed__)) ptp_header {
		uint8_t 	messageType;
		uint8_t		versionPTP;
		uint16_t	len;
		uint8_t		domain;
		uint8_t		reserved;
		uint16_t	flags;
		uint64_t	correction;
		uint32_t	reserved;
		uint8_t		oui[3];
		uint8_t		uuid[5];
		uint16_t	ptpNode_port;
		uint16_t	sequenceId;
		uint8_t		control;
		uint8_t		logMessageInterval;
	};

	struct __attribute__((__packed__)) udp_packet {
		struct ethernet_header  eth;
		struct ipv4_header 	ip;
		struct udp_header 	udp;
		uint8_t			payload[];
	};

	struct __attribute__((__packed__)) ethernet_packet {
		struct ethernet_header  eth;
		uint8_t			payload[];
	};

	struct __attribute__((__packed__)) udp_v6_packet {
		struct ethernet_header  eth;
		struct ipv6_header 	ip;
		struct udp_header 	udp;
		uint8_t			payload[];
	};

	struct __attribut__(__packed__)) ptp_packet{
		struct ethernet_header eth;
		struct ptp_header ptp;
	};
]]

return ffi.C
