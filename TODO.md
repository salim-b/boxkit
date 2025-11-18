# TODOs

- Incorporate our custom `~/.config/distrobox/*` config files into the repo (maybe just in the README?) 

- Add `--link` to `COPY` cmds in containerfiles once we upgraded to buildah v1.41.0+ that brings support for it.

  Note that also the GH action runner must have buildah v1.41.0+. Currently we're on
  [`ubuntu-24.04`](https://github.com/salim-b/boxkit/blob/main/.github/workflows/build-boxkit.yml#L22) which [ships buildah
  v1.33.7](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#tools). Lazy-op is to wait for `ubuntu-26.04`. 😌
