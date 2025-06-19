# Zen Browser

Fix audio issues (mic being quiet):

1. Access `about:config`
2. Search `media.getusermedia.microphone.prefer_voice_stream_with_processing.enabled` and change value to `FALSE`.
3. Search `media.getusermedia.channels` or `media.getusermedia.audio.max_channels` (depending on the Firefox version) and change the value to `1`.

