--! @file pcap-test.lua
--! @brief This is a simple test for MoonGen's pcap inport and export functionality

local mg		= require "dpdk"
local memory	= require "memory"
local device	= require "device"
local log		= require "log"
local ts 		= require "timestamping"
local pcap		= require "pcap"

function master(txPort, maxp, source)
	if not txPort then
		return log:info([[

Usage: txPort [maxp] [sink]

Reads packets from sink and writes them out on txPrt.
Transmits at most maxp packets or the entire pcap file if maxp == 0

Example usage:

sudo ./build/MoonGen examples/pcap-test.lua 0			# transmits entire contents of port-0.pcap on port 0
sudo ./build/MoonGen examples/pcap-test.lua 1 100 foo.pcap	# transmits 100 packets from foo.pcap on port 1
]])
	end
	source = source or "port-"..rxPort..'.pcap'
	if maxp == 0 then maxp = nil end
	local txDev = device.config{ port = txPort, txQueues = 1 }
	mg.sleepMillis(100)
		
	mg.launchLua("pcapLoadSlave", txDev:getTxQueue(0), source, maxp)
	mg.waitForSlaves()
end


--! @brief: sends a packet out
function pcapLoadSlave(queue, source, maxp)
	queue:setRate(10000)
	print('pcapLoadSlave is running')
	local mem = memory.createMemPool()
	local bufs = mem:bufArray(128)
	bufs:alloc(124)
	local pcapReader = pcapReader:newPcapReader(source, 10000)
	local pkt = 1
	while mg.running() and not pcapReader.done and (not maxp or pkt <= maxp) do
		local realp = 1
		while not pcapReader.done and (not maxp or pkt <= maxp) and (realp <= 128) do
			pcapReader:readPkt(bufs[realp], true)
			realp = realp + 1
			pkt = pkt + 1
		end
		queue:sendWithDelay(bufs, nil, nil, realp-1)
		print("pcapLoadSlave: Sent",realp-1,"packets")
	end

	mg.sleepMillis(500)
	print("pcapLoadSlave: end")
end
