
FROM ubuntu:bionic
LABEL maintainer="webispy@gmail.com" \
      version="0.2" \
      description="checkpatch and cppcheck for gerrit message"

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=en_US.UTF-8 \
    LANG=$LC_ALL

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates language-pack-en \
		cppcheck \
		git \
		patch \
		python-pip \
		sed \
		wget \
		&& locale-gen $LC_ALL \
		&& dpkg-reconfigure locales \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# gerrit-check
# - fix flake8 python version issue
# - add cppcheck option (--enable=all, --quiet)
# - remove Code-Review: -1
#RUN pip install --trusted-host pypi.python.org --upgrade pip==9.0.3 \
#	&& pip install --trusted-host pypi.python.org gerrit-check \
RUN pip install setuptools \
	&& pip install wheel \
	&& pip install gerrit-check \
	&& sed -i 's/from flake8.engine/from flake8.api.legacy/' /usr/local/lib/python2.7/dist-packages/gerritcheck/check.py \
	&& sed -i 's/"--quiet"/"--quiet", "--enable=all"/' /usr/local/lib/python2.7/dist-packages/gerritcheck/check.py \
	&& sed -i 's/review\["labels"\] = {"Code-Review": -1}/ /' /usr/local/lib/python2.7/dist-packages/gerritcheck/check.py \
	&& touch /usr/local/lib/python2.7/dist-packages/gerritcheck/check.py

# checkpatch
# https://raw.githubusercontent.com/01org/zephyr/master/scripts/checkpatch.pl
RUN mkdir /usr/share/codespell \
	&& wget --no-check-certificate https://raw.githubusercontent.com/torvalds/linux/master/scripts/checkpatch.pl -P /usr/bin/ \
	&& wget --no-check-certificate https://raw.githubusercontent.com/torvalds/linux/master/scripts/spelling.txt -P /usr/bin/ \
	&& wget --no-check-certificate https://raw.githubusercontent.com/nfs-ganesha/ci-tests/master/checkpatch/checkpatch-to-gerrit-json.py -P /usr/bin/ \
	&& chmod +x /usr/bin/checkpatch.pl \
	&& chmod +x /usr/bin/checkpatch-to-gerrit-json.py

COPY run_checkpatch.sh /usr/bin/
COPY run_cppcheck.sh /usr/bin/

COPY patches/0001-checkpatch-add-option-for-excluding-directories.patch /tmp
COPY patches/0002-ignore_const_struct_warning.patch /tmp
COPY patches/0003-gerrit_checkpatch.patch /tmp
RUN cd /usr/bin \
	&& cat /tmp/0001-checkpatch-add-option-for-excluding-directories.patch | patch \
	&& cat /tmp/0002-ignore_const_struct_warning.patch | patch \
	&& cat /tmp/0003-gerrit_checkpatch.patch | patch

CMD ["/bin/bash"]
