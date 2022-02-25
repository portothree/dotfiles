{ config, pkgs, ... }:

{
	home = {
		username = "porto";
		homeDirectory = "/home/porto";
		stateVersion = "22.05";
		packages = with pkgs; [
			st
			alacritty
			htop
			direnv
			fzf
			sysz
			ranger
			git
			tig
			google-cloud-sdk
			k9s
			kubectl
			qutebrowser
			ripgrep
			xclip
			keynav
			xdotool
			bspwm
			sxhkd
			lemonbar
			rofi
			pywal
			mopidy
			mopidy-iris
			cava
			astyle
			shfmt
			glow
			fira-code
			siji
			unclutter
			dunst
			weechat
			pgcli
			mycli
			wuzz
			websocat
			zathura
			taskwarrior
			weechat
			pulsemixer
		];
	};
	nixpkgs = {
		config = {
			allowUnfree = true;
		};
	};
	programs = {
		home-manager = {
			enable = true;
		};
		zsh = {
			enable = true;
			enableAutosuggestions = true;
			enableCompletion = true;
			sessionVariables = {
				PROMPT = "%(?.%F{green}.%F{red})λ%f %B%F{cyan}%~%f%b ";
				VISUAL = "vim";
				EDITOR = "vim";
				HISTTIMEFORMAT = "%F %T ";
				PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/nix/var/nix/profiles/default/bin:/home/porto/nix-profile/bin";
				NIX_PATH = "/home/porto/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
				LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
				MEMEX = "/home/porto/www/memex";
				FZF_DEFAULT_COMMAND = "rg --files | fzf";
				TASKWARRIOR_LOCATION_PATH = "/home/porto/www/memex/trails/tasks/.task";
			};
			shellAliases = {
				r = "ranger";
				krita = "QT_XCB_GL_INTEGRATION=none krita";
				rgf = "rg --files | rg";
				ksns = "kubectl api-resources --verbs=list --namespaced -o name | xargs -n1 kubectl get '$@' --show-kind --ignore-not-found";
				krns = "kubectl api-resources --namespaced=true --verbs=delete -o name | tr '\n' ',' | sed -e 's/,$//'"; 
				kdns = "kubectl delete '$(krns)' --all";
			};
			initExtraFirst = ''
				source "$(fzf-share)/key-bindings.zsh"
				source "$(fzf-share)/completion.zsh"
				[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)
				eval "$(direnv hook zsh)"

				# Load crontab from .crontab file
				if test -z $CRONTABCMD; then
					export CRONTABCMD=$(which crontab)

					crontab() {
						if [[ $@ == "-e" ]]; then
							vim "$HOME/.crontab" && $CRONTABCMD "$HOME/.crontab"
						else
							$CRONTABCMD $@
						fi
					 }
				   
					$CRONTABCMD "$HOME/.crontab"
				fi
			'';
			oh-my-zsh = {
				enable = true;
				plugins = [ "git" "git-auto-fetch" ];
				theme = "robbyrussell";
			};
		};
		vim = {
			enable = true;
			settings = {
				background = "dark";
				number = true;
				tabstop = 4;
				shiftwidth = 4;
            };
            plugins = with pkgs.vimPlugins; [
              vimwiki
              dracula-vim
            ];
            extraConfig = ''
              set clipboard=unnamedplus
              set t_Co=256
              set autoindent
              set nocp
              filetype plugin indent on
              syntax on 

              packadd! dracula
              colorscheme dracula

              au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger
			'';
		};
		git = {
			enable = true;
			userName = "Gustavo Porto";
			userEmail = "gustavoporto@ya.ru";
			extraConfig = {
				core = {
					editor = "vim";
				};
				color = {
					ui = true;
				};
				push = {
					default = "simple";
				};
				pull = {
					ff = "only";
				};
				init = {
					defaultBranch = "master";
				};
			};
			delta = {
				enable = true;
				options = {
					enable = true;
					options = {
						navigate = true;
						line-numbers = true;
						syntax-them = "Github";
					};
				};
			};
		};
		tmux = {
			enable = true;
			clock24 = true;
			keyMode = "vi";
			plugins = with pkgs.tmuxPlugins; [
				sensible
				yank
				{
					plugin = dracula;
					extraConfig = ''
						set -g @dracula-show-battery false
						set -g @dracula-show-powerline true
						set -g @dracula-refresh-rate 60
					'';
				}
			];
			extraConfig = ''
				set -g mouse off 
				bind h select-pane -L
				bind j select-pane -D
				bind k select-pane -U
				bind l select-pane -R
			'';
		};
		bat = {
			enable = true;
			config = {
				theme = "Github";
				italic-text = "always";
			};
		};
	};
}
