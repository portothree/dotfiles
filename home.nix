{ config, pkgs, ... }:

{
	home = {
		username = "porto";
		homeDirectory = "/home/porto";
		stateVersion = "22.05";
		packages = with pkgs; [
			vim
			htop
			direnv
			fzf
			git
			google-cloud-sdk
			k9s
			kubectl
			qutebrowser
			ripgrep
			tig
			xclip
			keynav
			xdotool
			bat
		];
	};
	programs = {
		home-manager = {
			enable = true;
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
