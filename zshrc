#
# /etc/zshrc is sourced in interactive shells.  It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#

_src_etc_profile_d()
{
	#  Make the *.sh things happier, and have possible ~/.zshenv options like
	# NOMATCH ignored.
	emulate -L ksh

	# from bashrc, with zsh fixes
	if [[ ! -o login ]]; then # We're not a login shell
		for i in /etc/profile.d/*.sh; do
			if [ -r "$i" ]; then
			. $i
			fi
		done
		unset i
	fi
}
_src_etc_profile_d

unset -f _src_etc_profile_d

autoload -U colors zsh-mime-setup select-word-style
colors          # colors
zsh-mime-setup  # run everything as if it's an executable

##
# Key bindings
##
# Lookup in /etc/termcap or /etc/terminfo else, you can get the right keycode
# by typing ^v and then type the key or key combination you want to use.
# "man zshzle" for the list of available actions
bindkey -e                                # emacs keybindings
bindkey ' '       magic-space             # also do history expansion on space
bindkey '\e[1;5C' forward-word            # C-Right
bindkey '\e[1;5D' backward-word           # C-Left
bindkey '\e[2~'   overwrite-mode          # Insert
bindkey '\e[3~'   delete-char             # Del
bindkey '\e[5~'   history-search-backward # PgUp
bindkey '\e[6~'   history-search-forward  # PgDn
bindkey '^A'      beginning-of-line       # Home
bindkey '^D'      delete-char             # Del
bindkey '^E'      end-of-line             # End
bindkey '^R'      history-incremental-pattern-search-backward

##
# Completion
##
autoload -U compinit
compinit
zmodload -i zsh/complist
setopt hash_list_all            # hash everything before completion
setopt completealiases          # complete alisases
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word
setopt complete_in_word         # allow completion from within a word/phrase
setopt correct                  # spelling correction for commands
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.

zstyle ':completion::complete:*' use-cache on               # completion caching, use rehash to clear
zstyle ':completion:*' cache-path ~/.zsh/cache              # cache path
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # ignore case
zstyle ':completion:*' menu select=2                        # menu if nb items > 2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}       # colorz !
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate # list of completers to use

# sections completion !
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'\e[00;34m%d'
zstyle ':completion:*:messages' format $'\e[00;31m%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true

zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=29=34"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always
#users=($(cat /etc/passwd | egrep 'bash|zsh' | sed -r 's/([^:]+):.*/\1/' | paste -d ' ' -s))
#zstyle ':completion:*' users $users

#generic completion with --help
compdef _gnu_generic gcc
compdef _gnu_generic gdb

##
# Pushd
##
setopt auto_pushd               # make cd push old dir in dir stack
setopt pushd_ignore_dups        # no duplicates in dir stack
setopt pushd_silent             # no dir stack after pushd or popd
setopt pushd_to_home            # `pushd` = `pushd $HOME`
#
##
# History
##
HISTFILE=~/.zsh_history         # where to store zsh config
HISTSIZE=1024                   # big history
SAVEHIST=1024                   # big history
setopt append_history           # append
setopt hist_ignore_all_dups     # no duplicate
unsetopt hist_ignore_space      # ignore space prefixed commands
setopt hist_reduce_blanks       # trim blanks
setopt hist_verify              # show before executing history commands
setopt inc_append_history       # add commands as they are typed, don't wait until shell exit
setopt share_history            # share hist between sessions
setopt bang_hist                # !keyword

##
# Various
##
setopt auto_cd                  # if command is a path, cd into it
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt correct                  # try to correct spelling of commands
setopt extended_glob            # activate complex pattern globbing
setopt glob_dots                # include dotfiles in globbing
setopt print_exit_value         # print return value if non-zero
unsetopt beep                   # no bell on error
#unsetopt bg_nice                # no lower prio for background jobs
#unsetopt clobber                # must use >| to truncate existing files
unsetopt hist_beep              # no bell on error in history
#unsetopt hup                    # no hup signal at shell exit
unsetopt ignore_eof             # do not exit on end-of-file
unsetopt list_beep              # no bell on ambiguous completion
unsetopt rm_star_silent         # ask for confirmation for `rm *' or `rm path/*'
typeset -U path
print -Pn "\e]0; %n@%M: %~\a"   # terminal title
EPORTTIME=4						# report CPU usage and timing for commands running longer than this seconds
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'	# don't stop C-w on this chars

##
# VCS
##
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats '%F{5} (%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%%b%F{4}'
zstyle ':vcs_info:*' formats       ' (%F{5}%b%%b%F{4})%a'

zstyle ':vcs_info:*' enable git
precmd () { vcs_info }

##
# Prompt
##
setopt PROMPT_SUBST     # allow funky stuff in prompt
PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%M %{$fg_bold[blue]%}%~${vcs_info_msg_0_} %(!.#.$)%{$reset_color%} '

##
# iTerm v3 shell integration
##
if [[ -o login ]]; then
	if [ "$TERM" != "screen" -a "$ITERM_SHELL_INTEGRATION_INSTALLED" = "" ]; then
		export ITERM_SHELL_INTEGRATION_INSTALLED=Yes
		ITERM2_SHOULD_DECORATE_PROMPT="1"
		# Indicates start of command output. Runs just before command executes.
		iterm2_before_cmd_executes() {
			printf "\033]133;C;\007"
		}

		iterm2_set_user_var() {
			printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(printf "%s" "$2" | base64)
		}

		# Users can write their own version of this method. It should call
		# iterm2_set_user_var but not produce any other output.
		# e.g., iterm2_set_user_var currentDirectory $PWD
		# Accessible in iTerm2 (in a badge now, elsewhere in the future) as
		# \(user.currentDirectory).
		whence -v iterm2_print_user_vars > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			iterm2_print_user_vars() {
			}
		fi

		iterm2_print_state_data() {
			printf "\033]1337;RemoteHost=%s@%s\007" "$USER" "$iterm2_hostname"
			printf "\033]1337;CurrentDir=%s\007" "$PWD"
			iterm2_print_user_vars
		}

		# Report return code of command; runs after command finishes but before prompt
		iterm2_after_cmd_executes() {
			printf "\033]133;D;%s\007" "$STATUS"
			iterm2_print_state_data
		}

		# Mark start of prompt
		iterm2_prompt_start() {
			printf "\033]133;A\007"
		}

		# Mark end of prompt
		iterm2_prompt_end() {
			printf "\033]133;B\007"
		}

		# There are three possible paths in life.
		#
		# 1) A command is entered at the prompt and you press return.
		#    The following steps happen:
		#    * iterm2_preexec is invoked
		#      * PS1 is set to ITERM2_PRECMD_PS1
		#      * ITERM2_SHOULD_DECORATE_PROMPT is set to 1
		#    * The command executes (possibly reading or modifying PS1)
		#    * iterm2_precmd is invoked
		#      * ITERM2_PRECMD_PS1 is set to PS1 (as modified by command execution)
		#      * PS1 gets our escape sequences added to it
		#    * zsh displays your prompt
		#    * You start entering a command
		#
		# 2) You press ^C while entering a command at the prompt.
		#    The following steps happen:
		#    * (iterm2_preexec is NOT invoked)
		#    * iterm2_precmd is invoked
		#      * iterm2_before_cmd_executes is called since we detected that iterm2_preexec was not run
		#      * (ITERM2_PRECMD_PS1 and PS1 are not messed with, since PS1 already has our escape
		#        sequences and ITERM2_PRECMD_PS1 already has PS1's original value)
		#    * zsh displays your prompt
		#    * You start entering a command
		#
		# 3) A new shell is born.
		#    * PS1 has some initial value, either zsh's default or a value set before this script is sourced.
		#    * iterm2_precmd is invoked
		#      * ITERM2_SHOULD_DECORATE_PROMPT is initialized to 1
		#      * ITERM2_PRECMD_PS1 is set to the initial value of PS1
		#      * PS1 gets our escape sequences added to it
		#    * Your prompt is shown and you may begin entering a command.
		#
		# Invariants:
		# * ITERM2_SHOULD_DECORATE_PROMPT is 1 during and just after command execution, and "" while the prompt is
		#   shown and until you enter a command and press return.
		# * PS1 does not have our escape sequences during command execution
		# * After the command executes but before a new one begins, PS1 has escape sequences and
		#   ITERM2_PRECMD_PS1 has PS1's original value.
		iterm2_decorate_prompt() {
			# This should be a raw PS1 without iTerm2's stuff. It could be changed during command
			# execution.
			ITERM2_PRECMD_PS1="$PS1"
			ITERM2_SHOULD_DECORATE_PROMPT=""

			# Add our escape sequences just before the prompt is shown.
			PS1="%{$(iterm2_prompt_start)%}$PS1%{$(iterm2_prompt_end)%}"
		}

		iterm2_precmd() {
			local STATUS="$?"
			if [ -z "$ITERM2_SHOULD_DECORATE_PROMPT" ]; then
				# You pressed ^C while entering a command (iterm2_preexec did not run)
				iterm2_before_cmd_executes
			fi

			iterm2_after_cmd_executes "$STATUS"

			if [ -n "$ITERM2_SHOULD_DECORATE_PROMPT" ]; then
				iterm2_decorate_prompt
			fi
		}

		# This is not run if you press ^C while entering a command.
		iterm2_preexec() {
			# Set PS1 back to its raw value prior to executing the command.
			PS1="$ITERM2_PRECMD_PS1"
			ITERM2_SHOULD_DECORATE_PROMPT="1"
			iterm2_before_cmd_executes
		}

		# If hostname -f is slow on your system, set iterm2_hostname prior to sourcing this script.
		[[ -z "$iterm2_hostname" ]] && iterm2_hostname=`hostname -f`

		[[ -z $precmd_functions ]] && precmd_functions=()
		precmd_functions=($precmd_functions iterm2_precmd)

		[[ -z $preexec_functions ]] && preexec_functions=()
		preexec_functions=($preexec_functions iterm2_preexec)

		iterm2_print_state_data
		printf "\033]1337;ShellIntegrationVersion=2;shell=zsh\007"
	fi
fi

source ~/.profile

