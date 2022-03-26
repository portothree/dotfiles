## Patching
1. Apply patch with `patch --merge -i /path/to/patch.diff`
2. Rebuild st with `rm -rf config.h && sudo make clean install`

