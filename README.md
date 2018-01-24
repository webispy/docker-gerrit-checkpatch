# checkpatch for Gerrit

cppcheck and checkpatch.pl

## Quick start

```sh
docker pull webispy/gerrit-checkpatch
docker run --rm -v {your-git-repository}:/src webispy/gerrit-checkpatch run_checkpatch.sh {commit-id}
```

# References

- https://github.com/nfs-ganesha/ci-tests
- https://github.com/grundprinzip/gerrit-check

