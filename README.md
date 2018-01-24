[![Docker Pulls](https://img.shields.io/docker/pulls/webispy/gerrit-checkpatch.svg)](https://hub.docker.com/r/webispy/gerrit-checkpatch/) [![Docker Build Status](https://img.shields.io/docker/build/webispy/gerrit-checkpatch.svg)](https://hub.docker.com/r/webispy/gerrit-checkpatch/)

# checkpatch for Gerrit

[cppcheck](http://cppcheck.sourceforge.net/) and [checkpatch.pl](https://github.com/torvalds/linux/tree/master/scripts) for [Gerrit](https://www.gerritcodereview.com/) code review

## Quick start

```sh
$ docker pull webispy/gerrit-checkpatch

# checkpatch
$ docker run --rm -v {your-git-repository}:/src webispy/gerrit-checkpatch bash -c "cd /src; run_checkpatch.sh {commit-id}"

# cppcheck
$ docker run --rm -v {your-git-repository}:/src webispy/gerrit-checkpatch bash -c "cd /src; run_cppcheck.sh {commit-id}"
```

## Examples - commit for sample/main.c

```sh
$ git clone https://github.com/webispy/gerrit-checkpatch
$ cd gerrit-checkpatch

# sample code
$ git show b7d399c
commit b7d399c1aa4dacbdcc68fedcc26db3de215eb079
Author: Inho Oh <webispy@gmail.com>
Date:   Wed Jan 24 14:24:23 2018 +0900

    Add sample code
    
    Signed-off-by: Inho Oh <webispy@gmail.com>

diff --git a/sample/main.c b/sample/main.c
new file mode 100644
index 0000000..cdc0869
--- /dev/null
+++ b/sample/main.c
@@ -0,0 +1,12 @@
+#include <stdio.h>
+
+int main(int argc, char *argv[])
+{
+       int buglist[3];
+
+       buglist[3] = 0x18;
+
+               buglist[0] = 1; /* invalid indentation with whitespace */ 
+
+       return 0;
+}

# checkpatch.pl - check the coding convention (linux kernel style)
$ docker run --rm -v ~/gerrit-checkpatch:/src webispy/gerrit-checkpatch bash -c "cd /src; run_checkpatch.sh b7d399c" | json_pp
{
   "message" : "Checkpatch total: 1 errors, 1 warnings, 12 lines checked",
   "comments" : {
      "sample/main.c" : [
         {
            "message" : "ERROR: trailing whitespace\n+^I^Ibuglist[0] = 1; /* invalid indentation with whitespace */ $",
            "line" : "9"
         }
      ],
      "/COMMIT_MSG" : [
         {
            "message" : "WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?\nnew file mode 100644"
         }
      ]
   }
}

# cppcheck - static analysis
$ docker run --rm -v ~/gerrit-checkpatch:/src webispy/gerrit-checkpatch bash -c "cd /src; run_cppcheck.sh b7d399c" | json_pp
{
   "comments" : {
      "sample/main.c" : [
         {
            "message" : "[error] Array 'buglist[3]' accessed at index 3, which is out of bounds.",
            "line" : "7",
            "path" : "sample/main.c"
         }
      ]
   },
   "message" : "[CPPCHECK] Some issues need to be fixed.",
   "labels" : {
      "Code-Review" : -1
   }
}
```

# References

- https://github.com/nfs-ganesha/ci-tests
- https://github.com/grundprinzip/gerrit-check

