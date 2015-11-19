.PHONY = all
all:
	haxe build.hxml && \
	echo "Processing index.xml" && \
	neko run.n xml/index.xml doc/ && \
	echo "Processing stats.xml" && \
	neko run.n xml/stats.xml doc/ && \
	echo "Processing uniserver.xml" && \
	neko run.n xml/uniserver.xml doc/
#	&& \
#	vim +"helptags ~/.vim/doc/"

