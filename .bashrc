# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# other history settings
HISTSIZE=5000
HISTFILESIZE=10000
HISTIGNORE='ls:bg:fg:history:eza:ll:la:l:clear:exit:pwd:cd:cd -:cd ..:cd ~:cd -'

# colors

RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"
BOLD="\[\033[1m\]"
RESET="\[\033[0m\]"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a nname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Boring old prompt:

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt
#
# # If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

# Function to parse the current git branch
function parse_git_branch() {
    BRANCH=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ -n "$BRANCH" ]; then
        STAT=$(parse_git_dirty)
        echo "[${BRANCH}${STAT}]"
    fi
}

# Function to parse git status for changes
function parse_git_dirty() {
    status=$(git status 2>&1)
    dirty=$(echo "$status" | grep "modified:" &>/dev/null; echo $?)
    untracked=$(echo "$status" | grep "Untracked files" &>/dev/null; echo $?)
    ahead=$(echo "$status" | grep "Your branch is ahead of" &>/dev/null; echo $?)
    newfile=$(echo "$status" | grep "new file:" &>/dev/null; echo $?)
    renamed=$(echo "$status" | grep "renamed:" &>/dev/null; echo $?)
    deleted=$(echo "$status" | grep "deleted:" &>/dev/null; echo $?)

    bits=""
    [ $renamed -eq 0 ] && bits=">${bits}"
    [ $ahead -eq 0 ] && bits="*${bits}"
    [ $newfile -eq 0 ] && bits="+${bits}"
    [ $untracked -eq 0 ] && bits="?${bits}"
    [ $deleted -eq 0 ] && bits="x${bits}"
    [ $dirty -eq 0 ] && bits="!${bits}"

    echo "$bits"
}

# Export the prompt
export PS1="${BOLD}${BLUE}[\u@\h]${RESET} ${BOLD}${GREEN}\w${RESET} ${PURPLE}\$(parse_git_branch)${RESET} \n${BOLD}${WHITE}\\$ ⮞ ${RESET}"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    # alias ls='ls --color=auto --group-directories-first'
    alias ls='eza --dereference --extended --git --time-style=relative --group-directories-first --oneline --icons=never --header --dereference --mounts'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# search history function
search-history() {
    history | grep --color=auto -i "$1"
}

# search for leaks in binary
valgrind-check() {
    valgrind --leak-check=full \
            --show-leak-kinds=all \
            --track-origins=yes \
            --verbose \
            --log-file=valgrind-out.log \
            "$@"
}

. "$HOME/.cargo/env"

export PATH=$PATH:/home/lain/Software/bin
