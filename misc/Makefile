BANNER=NodeMCU Linux

all::	banner.bw.txt banner.co.txt

banner.bw.txt::
	toilet -f small "${BANNER}" > banner.bw.txt

banner.co.txt::
	toilet -f small --filter metal "${BANNER}" > banner.co.txt


