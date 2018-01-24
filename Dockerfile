
FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="checkpatch and cppcheck for gerrit message"

ARG http_proxy
ARG https_proxy

ENV http_proxy=$http_proxy \
    https_proxy=$https_proxy \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=en_US.UTF-8 \
    LANG=$LC_ALL

RUN apt-get update && apt-get install -y \
		ca-certificates language-pack-en \
		cppcheck \
		git \
		python-pip \
		software-properties-common \
		sed \
		vim \
		wget \
		&& locale-gen $LC_ALL \
		&& dpkg-reconfigure locales \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# gerrit-check
RUN pip install --trusted-host pypi.python.org --upgrade pip \
	&& pip install --trusted-host pypi.python.org gerrit-check \
	&& sed -i 's/from flake8.engine/from flake8.api.legacy/' /usr/local/lib/python2.7/dist-packages/gerritcheck/check.py \
	&& touch /usr/local/lib/python2.7/dist-packages/gerritcheck/check.py

# checkpatch
RUN mkdir /usr/share/codespell \
	&& wget --no-check-certificate https://raw.githubusercontent.com/torvalds/linux/master/scripts/checkpatch.pl -P /usr/bin/ \
	&& wget --no-check-certificate https://raw.githubusercontent.com/torvalds/linux/master/scripts/spelling.txt -P /usr/bin/ \
	&& wget --no-check-certificate https://raw.githubusercontent.com/nfs-ganesha/ci-tests/master/checkpatch/checkpatch-to-gerrit-json.py -P /usr/bin/ \
	&& chmod +x /usr/bin/checkpatch.pl \
	&& chmod +x /usr/bin/checkpatch-to-gerrit-json.py

COPY run_checkpatch.sh /usr/bin/
COPY run_cppcheck.sh /usr/bin/

CMD ["/bin/bash"]
