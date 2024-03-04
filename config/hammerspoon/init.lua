-- Disables the Music app
function applicationMusicWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.launching) then
        if (appName == "Music") then
            local op, stat, typ, ec = hs.execute([["/usr/bin/killall" "Music"]])
            if not (ec == 0) then
                msg = "An error occurred terminating Music."
                hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
            end                     
        end
    end
end
appMusicWatcher = hs.application.watcher.new(applicationMusicWatcher)
appMusicWatcher:start()
