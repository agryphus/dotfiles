export PATH=$PATH:~/.cargo/bin/

alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias python='python3'

# Print out all colors
alias colors='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$"\n"}; done'

# ZSH Configurations
unsetopt autocd            # Change directory just by typing its name (hurts performance)
setopt interactivecomments # Allow comments in interactive mode
setopt magicequalsubst     # Enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # Hide error message if there is no match for the pattern
setopt notify              # Report the status of background jobs immediately
setopt numericglobsort     # Sort filenames numerically when it makes sense
setopt promptsubst         # Enable command substitution in prompt

# Colors
alias ls='ls --color=auto --group-directories-first -hN'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
LS_COLORS+=':ow=01;33' # Remove green background of simlinks

# Don't consider certain characters part of the word
WORDCHARS=${WORDCHARS//\/} 

# Enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
alias history="history 0"     # force zsh to show the complete history

# Building the prompt
C_PROMPT="%F{cyan}"
C_GIT="%F{green}"
C_DIR="%F{yellow}"
C_RESET="%F{reset}"
RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})'
err="$?"
curr_time="%*"
dir='%(2~|.../%2~|%~)' # 2 deep, or truncation
git_info=''

function precmd {
    PROMPT="${C_PROMPT}[${curr_time}${C_DIR}:${dir}${C_PROMPT}]$(parse_git)${C_RESET}$ "
}

function parse_git() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo ""
        return
    fi

    # Get branch
    local branch
    branch="$(git symbolic-ref HEAD 2> /dev/null)"
    branch="${branch#refs/heads/}"
    # If we're in detached HEAD the above doesn't work, so use reflog instead
    [[ -z $branch ]] && branch="$(git reflog HEAD | grep 'checkout:' | head -n1 | grep -oE '[^ ]+$')"

    # Check dirty status
    [[ -z $(git status --porcelain 2> /dev/null) ]] \
    && dirty="%F{green}✓${C_RESET}" \
    || dirty="%F{red}✗${C_RESET}"

    # Get our branch or ref, depending if we're in detached HEAD or not.
    ref=$(git symbolic-ref HEAD 2>/dev/null) \
    && { ref=${ref#refs/heads/} ; branch="$ref" ; } \
    || ref=$(git reflog HEAD | awk 'NR==1 && /checkout:/ { print $NF }')

    # Checking number of comits ahead or behind
    upstream_ref=$(git for-each-ref --format='%(refname:short)|%(upstream:short)' refs/heads \
     | grep "^$branch|" \
     | cut -d'|' -f2)

    if [[ "$upstream_ref" ]]; then
        updown=( $(git rev-list --count --left-right "$upstream_ref"...HEAD) )

        [[ ${updown[0]} -gt 0 ]] && tracking+="%F{cyan}-${updown[0]}${C_RESET}:"    # Behind
        [[ ${updown[1]} -gt 0 ]] && tracking+="%F{magenta}+${updown[1]}${C_RESET}:" # Ahead
    fi

    # Put together our prompt string
    git_prompt+="\n${C_GIT}["
    git_prompt+="${ref}:${C_RESET}"
    git_prompt+="${tracking}"
    git_prompt+="${dirty}"
    git_prompt+="${C_GIT}]${C_RESET}"

    echo "$git_prompt"
}

# Config for zsh-syntax-highlighting
LIGHT_GREY=242
unsetopt ksharrays # 0-indexing arrays breaks plugin :(
. ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[arg0]=fg=yello
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=$LIGHT_GREY
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=$LIGHT_GREY
ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout

# Unset styles
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[assign]=none
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[named-fd]=none
ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[command-substitution]=none
ZSH_HIGHLIGHT_STYLES[process-substitution]=none
ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

