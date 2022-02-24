{ config, pkgs, ... }:

{
	home = {
		username = "porto";
		homeDirectory = "/home/porto";
		stateVersion = "22.05";
		packages = with pkgs; [
			zsh
			st
			alacritty
			vim
			htop
			direnv
			fzf
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
			bat
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
			nvtop
			weechat
			pgcli
			mycli
			wuzz
			websocat
			zathura
			taskwarrior
		];
	};
	programs = {
		home-manager = {
			enable = true;
		};
		zsh = {
			enable = true;
			oh-my-zsh = {
				enable = true;
			}
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
