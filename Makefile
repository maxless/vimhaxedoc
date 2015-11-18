.PHONY = all
all:
	haxe build.hxml && \
	neko run.n xml/index.xml doc/snipeapi-edit.txt && \
	neko run.n xml/stats.xml doc/snipeapi-stats.txt && \
	neko run.n xml/uniserver.xml doc/snipeapi-server.txt

