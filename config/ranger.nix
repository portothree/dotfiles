{ config, pkgs, ... }:

{

  home.file = {
    ranger-rc = {
      target = ".config/ranger/rc.conf";
      text = ''
        set viewmode miller
        set column_ratios 1,3,4
        set hidden_filter ^\.|\.(?:pyc|pyo|bak|swp)$|^lost\+found$|^__(py)?cache__$
        set show_hidden true
        set confirm_on_delete multiple
        set use_preview_script true
        set automatically_count_files true
        set open_all_images true
        set vcs_aware false
        set vcs_backend_git enabled
        set vcs_backend_hg disabled
        set vcs_backend_bzr disabled
        set vcs_backend_svn disabled
        set preview_images false
        set preview_images_method w3m
        set w3m_delay 0.02
        set unicode_ellipsis false
        set bidi_support false
        set show_hidden_bookmarks true
        set colorscheme default
        set preview_files true
        set preview_directories true
        set collapse_preview true
        set save_console_history true
        set status_bar_on_top false
        set draw_progress_bar_in_status_bar true
        set draw_borders none
        set dirname_in_tabs false
        set mouse_enabled false
        set display_size_in_main_column true
        set display_size_in_status_bar true
        set display_free_space_in_status_bar true
        set display_tags_in_all_columns true
        set update_title false
        set update_tmux_title true
        set shorten_title 3
        set hostname_in_titlebar true
        set tilde_in_titlebar true
        set max_history_size 20
        set max_console_history_size 50
        set scroll_offset 8
        set flushinput true
        set padding_right true
        set autosave_bookmarks false
        set save_backtick_bookmark true
        set autoupdate_cumulative_size false
        set show_cursor false
        set sort natural
        set sort_reverse false
        set sort_case_insensitive true
        set sort_directories_first true
        set sort_unicode false
        set xterm_alt_key false
        set cd_bookmarks true
        set cd_tab_case sensitive
        set cd_tab_fuzzy true
        set preview_max_size 0
        set hint_collapse_threshold 10
        set show_selection_in_titlebar true
        set idle_delay 2000
        set metadata_deep_search false
        set clear_filters_on_dir_change false
        set line_numbers false
        set relative_current_zero false
        set one_indexed false
        set save_tabs_on_exit false
        set wrap_scroll false
        set global_inode_type_filter
        set freeze_files false

        alias e     edit
        alias q     quit
        alias q!    quit!
        alias qa    quitall
        alias qa!   quitall!
        alias qall  quitall
        alias qall! quitall!
        alias setl  setlocal
        alias filter     scout -prts
        alias find       scout -aets
        alias mark       scout -mr
        alias unmark     scout -Mr
        alias search     scout -rs
        alias search_inc scout -rts
        alias travel     scout -aefklst

        map     Q quitall
        map     q quit
        copymap q ZZ ZQ
        map R     reload_cwd
        map F     set freeze_files!
        map <C-r> reset
        map <C-l> redraw_window
        map <C-c> abort
        map <esc> change_mode normal
        map ~ set viewmode!
        map i display_file
        map ? help
        map W display_log
        map w taskview_open
        map S shell $SHELL
        map :  console
        map ;  console
        map !  console shell%space
        map @  console -p6 shell  %%s
        map #  console shell -p%space
        map s  console shell%space
        map r  chain draw_possible_programs; console open_with%%space
        map f  console find%space
        map cd console cd%space
        map <C-p> chain console; eval fm.ui.console.history_move(-1)
        map Mf linemode filename
        map Mi linemode fileinfo
        map Mm linemode mtime
        map Mp linemode permissions
        map Ms linemode sizemtime
        map Mt linemode metatitle
        map t       tag_toggle
        map ut      tag_remove
        map "<any>  tag_toggle tag=%any
        map <Space> mark_files toggle=True
        map v       mark_files all=True toggle=True
        map uv      mark_files all=True val=False
        map V       toggle_visual_mode
        map uV      toggle_visual_mode reverse=True
        map <F1> help
        map <F2> rename_append
        map <F3> display_file
        map <F4> edit
        map <F5> copy
        map <F6> cut
        map <F7> console mkdir%space
        map <F8> console delete
        map <F10> exit
        map <UP>       move up=1
        map <DOWN>     move down=1
        map <LEFT>     move left=1
        map <RIGHT>    move right=1
        map <HOME>     move to=0
        map <END>      move to=-1
        map <PAGEDOWN> move down=1   pages=True
        map <PAGEUP>   move up=1     pages=True
        map <CR>       move right=1
        #map <DELETE>   console delete
        map <INSERT>   console touch%space
        copymap <UP>       k
        copymap <DOWN>     j
        copymap <LEFT>     h
        copymap <RIGHT>    l
        copymap <HOME>     gg
        copymap <END>      G
        copymap <PAGEDOWN> <C-F>
        copymap <PAGEUP>   <C-B>
        map J  move down=0.5  pages=True
        map K  move up=0.5    pages=True
        copymap J <C-D>
        copymap K <C-U>
        map H     history_go -1
        map L     history_go 1
        map ]     move_parent 1
        map [     move_parent -1
        map }     traverse
        map {     traverse_backwards
        map )     jump_non
        map gh cd ~
        map ge cd /etc
        map gu cd /usr
        map gd cd /dev
        map gl cd -r .
        map gL cd -r %f
        map go cd /opt
        map gv cd /var
        map gm cd /media
        map gi eval fm.cd('/run/media/' + os.getenv('USER'))
        map gM cd /mnt
        map gs cd /srv
        map gp cd /tmp
        map gr cd /
        map gR eval fm.cd(ranger.RANGERDIR)
        map g/ cd /
        map g? cd /usr/share/doc/ranger
        map E  edit
        map du shell -p du --max-depth=1 -h --apparent-size
        map dU shell -p du --max-depth=1 -h --apparent-size | sort -rh
        map yp yank path
        map yd yank dir
        map yn yank name
        map y. yank name_without_extension
        map =  chmod
        map cw console rename%space
        map a  rename_append
        map A  eval fm.open_console('rename ' + fm.thisfile.relative_path.replace("%", "%%"))
        map I  eval fm.open_console('rename ' + fm.thisfile.relative_path.replace("%", "%%"), position=7)
        map pp paste
        map po paste overwrite=True
        map pP paste append=True
        map pO paste overwrite=True append=True
        map pl paste_symlink relative=False
        map pL paste_symlink relative=True
        map phl paste_hardlink
        map pht paste_hardlinked_subtree
        map dD console delete
        map dd cut
        map ud uncut
        map da cut mode=add
        map dr cut mode=remove
        map dt cut mode=toggle
        map yy copy
        map uy uncut
        map ya copy mode=add
        map yr copy mode=remove
        map yt copy mode=toggle
        map dgg eval fm.cut(dirarg=dict(to=0), narg=quantifier)
        map dG  eval fm.cut(dirarg=dict(to=-1), narg=quantifier)
        map dj  eval fm.cut(dirarg=dict(down=1), narg=quantifier)
        map dk  eval fm.cut(dirarg=dict(up=1), narg=quantifier)
        map ygg eval fm.copy(dirarg=dict(to=0), narg=quantifier)
        map yG  eval fm.copy(dirarg=dict(to=-1), narg=quantifier)
        map yj  eval fm.copy(dirarg=dict(down=1), narg=quantifier)
        map yk  eval fm.copy(dirarg=dict(up=1), narg=quantifier)
        map /  console search%space
        map n  search_next
        map N  search_next forward=False
        map ct search_next order=tag
        map cs search_next order=size
        map ci search_next order=mimetype
        map cc search_next order=ctime
        map cm search_next order=mtime
        map ca search_next order=atime
        map <C-n>     tab_new
        map <C-w>     tab_close
        map <TAB>     tab_move 1
        map <S-TAB>   tab_move -1
        map <A-Right> tab_move 1
        map <A-Left>  tab_move -1
        map gt        tab_move 1
        map gT        tab_move -1
        map gn        tab_new
        map gc        tab_close
        map uq        tab_restore
        map <a-1>     tab_open 1
        map <a-2>     tab_open 2
        map <a-3>     tab_open 3
        map <a-4>     tab_open 4
        map <a-5>     tab_open 5
        map <a-6>     tab_open 6
        map <a-7>     tab_open 7
        map <a-8>     tab_open 8
        map <a-9>     tab_open 9
        map <a-r>     tab_shift 1
        map <a-l>     tab_shift -1
        map or set sort_reverse!
        map oz set sort=random
        map os chain set sort=size;      set sort_reverse=False
        map ob chain set sort=basename;  set sort_reverse=False
        map on chain set sort=natural;   set sort_reverse=False
        map om chain set sort=mtime;     set sort_reverse=False
        map oc chain set sort=ctime;     set sort_reverse=False
        map oa chain set sort=atime;     set sort_reverse=False
        map ot chain set sort=type;      set sort_reverse=False
        map oe chain set sort=extension; set sort_reverse=False
        map oS chain set sort=size;      set sort_reverse=True
        map oB chain set sort=basename;  set sort_reverse=True
        map oN chain set sort=natural;   set sort_reverse=True
        map oM chain set sort=mtime;     set sort_reverse=True
        map oC chain set sort=ctime;     set sort_reverse=True
        map oA chain set sort=atime;     set sort_reverse=True
        map oT chain set sort=type;      set sort_reverse=True
        map oE chain set sort=extension; set sort_reverse=True
        map dc get_cumulative_size
        map zc    set collapse_preview!
        map zd    set sort_directories_first!
        map zh    set show_hidden!
        map <C-h> set show_hidden!
        copymap <C-h> <backspace>
        copymap <backspace> <backspace2>
        map zI    set flushinput!
        map zi    set preview_images!
        map zm    set mouse_enabled!
        map zp    set preview_files!
        map zP    set preview_directories!
        map zs    set sort_case_insensitive!
        map zu    set autoupdate_cumulative_size!
        map zv    set use_preview_script!
        map zf    console filter%space
        copymap zf zz
        map .n console filter_stack add name%space
        map .m console filter_stack add mime%space
        map .d filter_stack add type d
        map .f filter_stack add type f
        map .l filter_stack add type l
        map .| filter_stack add or
        map .& filter_stack add and
        map .! filter_stack add not
        map .r console filter_stack rotate
        map .c filter_stack clear
        map .* filter_stack decompose
        map .p filter_stack pop
        map .. filter_stack show
        map `<any>  enter_bookmark %any
        map '<any>  enter_bookmark %any
        map m<any>  set_bookmark %any
        map um<any> unset_bookmark %any
        map m<bg>   draw_bookmarks
        copymap m<bg>  um<bg> `<bg> '<bg>

        eval for arg in "rwxXst": cmd("map +u{0} shell -f chmod u+{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map +g{0} shell -f chmod g+{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map +o{0} shell -f chmod o+{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map +a{0} shell -f chmod a+{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map +{0}  shell -f chmod u+{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map -u{0} shell -f chmod u-{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map -g{0} shell -f chmod g-{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map -o{0} shell -f chmod o-{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map -a{0} shell -f chmod a-{0} %s".format(arg))
        eval for arg in "rwxXst": cmd("map -{0}  shell -f chmod u-{0} %s".format(arg))

        cmap <tab>   eval fm.ui.console.tab()
        cmap <s-tab> eval fm.ui.console.tab(-1)
        cmap <ESC>   eval fm.ui.console.close()
        cmap <CR>    eval fm.ui.console.execute()
        cmap <C-l>   redraw_window
        copycmap <ESC> <C-c>
        copycmap <CR>  <C-j>
        cmap <up>    eval fm.ui.console.history_move(-1)
        cmap <down>  eval fm.ui.console.history_move(1)
        cmap <left>  eval fm.ui.console.move(left=1)
        cmap <right> eval fm.ui.console.move(right=1)
        cmap <home>  eval fm.ui.console.move(right=0, absolute=True)
        cmap <end>   eval fm.ui.console.move(right=-1, absolute=True)
        cmap <a-b> eval fm.ui.console.move_word(left=1)
        cmap <a-f> eval fm.ui.console.move_word(right=1)
        copycmap <a-b> <a-left>
        copycmap <a-f> <a-right>
        cmap <backspace>  eval fm.ui.console.delete(-1)
        cmap <delete>     eval fm.ui.console.delete(0)
        cmap <C-w>        eval fm.ui.console.delete_word()
        cmap <A-d>        eval fm.ui.console.delete_word(backward=False)
        cmap <C-k>        eval fm.ui.console.delete_rest(1)
        cmap <C-u>        eval fm.ui.console.delete_rest(-1)
        cmap <C-y>        eval fm.ui.console.paste()
        copycmap <ESC>       <C-g>
        copycmap <up>        <C-p>
        copycmap <down>      <C-n>
        copycmap <left>      <C-b>
        copycmap <right>     <C-f>
        copycmap <home>      <C-a>
        copycmap <end>       <C-e>
        copycmap <delete>    <C-d>
        copycmap <backspace> <C-h>
        copycmap <backspace> <backspace2>
        cmap <allow_quantifiers> false
        pmap  <down>      pager_move  down=1
        pmap  <up>        pager_move  up=1
        pmap  <left>      pager_move  left=4
        pmap  <right>     pager_move  right=4
        pmap  <home>      pager_move  to=0
        pmap  <end>       pager_move  to=-1
        pmap  <pagedown>  pager_move  down=1.0  pages=True
        pmap  <pageup>    pager_move  up=1.0    pages=True
        pmap  <C-d>       pager_move  down=0.5  pages=True
        pmap  <C-u>       pager_move  up=0.5    pages=True
        copypmap <UP>       k  <C-p>
        copypmap <DOWN>     j  <C-n> <CR>
        copypmap <LEFT>     h
        copypmap <RIGHT>    l
        copypmap <HOME>     g
        copypmap <END>      G
        copypmap <C-d>      d
        copypmap <C-u>      u
        copypmap <PAGEDOWN> n  f  <C-F>  <Space>
        copypmap <PAGEUP>   p  b  <C-B>
        pmap     <C-l> redraw_window
        pmap     <ESC> pager_close
        copypmap <ESC> q Q i <F3>
        pmap E      edit_file
        tmap <up>        taskview_move up=1
        tmap <down>      taskview_move down=1
        tmap <home>      taskview_move to=0
        tmap <end>       taskview_move to=-1
        tmap <pagedown>  taskview_move down=1.0  pages=True
        tmap <pageup>    taskview_move up=1.0    pages=True
        tmap <C-d>       taskview_move down=0.5  pages=True
        tmap <C-u>       taskview_move up=0.5    pages=True
        copytmap <UP>       k  <C-p>
        copytmap <DOWN>     j  <C-n> <CR>
        copytmap <HOME>     g
        copytmap <END>      G
        copytmap <C-u>      u
        copytmap <PAGEDOWN> n  f  <C-F>  <Space>
        copytmap <PAGEUP>   p  b  <C-B>
        tmap J          eval -q fm.ui.taskview.task_move(-1)
        tmap K          eval -q fm.ui.taskview.task_move(0)
        tmap dd         eval -q fm.ui.taskview.task_remove()
        tmap <pagedown> eval -q fm.ui.taskview.task_move(-1)
        tmap <pageup>   eval -q fm.ui.taskview.task_move(0)
        tmap <delete>   eval -q fm.ui.taskview.task_remove()
        tmap <C-l> redraw_window
        tmap <ESC> taskview_close
        copytmap <ESC> q Q w <C-c>
      '';
    };
    ranger-rifle = {
      target = ".config/ranger/rifle.conf";
      text = ''
        ext x?html?, has qutebrowser,      X, flag f = qutebrowser -- "$@"

        mime ^text,  label editor = "$EDITOR" -- "$@"
        mime ^text,  label pager  = "$PAGER" -- "$@"
        !mime ^text, label editor, ext xml|html|json|csv|tex|py|pl|rb|css|js|ts|nix|sh|php = "$EDITOR" -- "$@"
        !mime ^text, label pager,  ext xml|html|json|csv|tex|py|pl|rb|css|js|ts|nix|sh|php = "$PAGER" -- "$@"

        ext 1                         = man "$1"
        ext s[wmf]c, has zsnes, X     = zsnes "$1"
        ext s[wmf]c, has snes9x-gtk,X = snes9x-gtk "$1"
        ext nes, has fceux, X         = fceux "$1"
        ext exe                       = wine "$1"
        name ^[mM]akefile$            = make

        ext py  = python -- "$1"
        ext pl  = perl -- "$1"
        ext rb  = ruby -- "$1"
        ext js  = node -- "$1"
        ext ts = ts-node "$1"
        ext sh  = sh -- "$1"
        ext php = php -- "$1"

        mime ^audio|ogg$, terminal, has mpv      = mpv -- "$@"

        mime ^video,       has mpv,      X, flag f = mpv -- "$@"
        mime ^video,       has mpv,      X, flag f = mpv --fs -- "$@"
        mime ^video, terminal, !X, has mpv       = mpv -- "$@"

        ext pdf, has zathura,  X, flag f = zathura -- "$@"
        ext djvu, has zathura,X, flag f = zathura -- "$@"
        ext epub, has zathura,      X, flag f = zathura -- "$@"
        ext cbr,  has zathura,      X, flag f = zathura -- "$@"
        ext cbz,  has zathura,      X, flag f = zathura -- "$@"

        mime ^image/svg, has inkscape, X, flag f = inkscape -- "$@"
        mime ^image, has imv,       X, flag f = imv -- "$@"
        mime ^image, has gimp,      X, flag f = gimp -- "$@"
        ext xcf,                    X, flag f = gimp -- "$@"


        ext 7z, has 7z = 7z -p l "$@" | "$PAGER"
        ext tar|gz|bz2|xz, has tar = tar vvtf "$1" | "$PAGER"
        ext tar|gz|bz2|xz, has tar = for file in "$@"; do tar vvxf "$file"; done
        ext bz2, has bzip2 = for file in "$@"; do bzip2 -dk "$file"; done
        ext zip, has unzip = unzip -l "$1" | less
        ext ace, has unace = unace l "$1" | less
        ext ace, has unace = for file in "$@"; do unace e "$file"; done
        ext rar, has unrar = unrar l "$1" | less
        ext rar, has unrar = for file in "$@"; do unrar x "$file"; done

        mime ^font, has fontforge, X, flag f = fontforge "$@"

        mime ^ranger/x-terminal-emulator, has st = st -e "$@"

        label wallpaper, number 11, mime ^image, has feh, X = feh --bg-scale "$1"
        label wallpaper, number 12, mime ^image, has feh, X = feh --bg-tile "$1"
        label wallpaper, number 13, mime ^image, has feh, X = feh --bg-center "$1"
        label wallpaper, number 14, mime ^image, has feh, X = feh --bg-fill "$1"

        label open, has xdg-open = xdg-open -- "$@"
        label open, has open     = open -- "$@"

                      !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php  = ask
        label editor, !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php  = ${
          "VISUAL:-$EDITOR"
        } -- "$@"
        label pager,  !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php  = "$PAGER" -- "$@"

        mime application/x-executable = "$1"
      '';
    };
  };
}
