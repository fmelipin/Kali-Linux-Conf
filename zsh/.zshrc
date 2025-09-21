# ──────────────────────────────────────────────────────────────────────────────
# Powerlevel10k instant prompt (debe ir arriba de todo)
# ──────────────────────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Opciones de zsh
# ──────────────────────────────────────────────────────────────────────────────
setopt autocd
#setopt correct
setopt interactivecomments
setopt magicequalsubst
setopt nonomatch
setopt notify
setopt numericglobsort
setopt promptsubst

WORDCHARS=${WORDCHARS//\/}
PROMPT_EOL_MARK=""

# ──────────────────────────────────────────────────────────────────────────────
# Keybindings
# ──────────────────────────────────────────────────────────────────────────────
bindkey -e
bindkey ' '        magic-space
bindkey '^U'       backward-kill-line
bindkey '^[[3;5~'  kill-word
bindkey '^[[3~'    delete-char
bindkey '^[[1;5C'  forward-word
bindkey '^[[1;5D'  backward-word
bindkey '^[[5~'    beginning-of-buffer-or-history
bindkey '^[[6~'    end-of-buffer-or-history
bindkey '^[[H'     beginning-of-line
bindkey '^[[F'     end-of-line
bindkey '^[[Z'     undo

# ──────────────────────────────────────────────────────────────────────────────
# Completion
# ──────────────────────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# Colores para completion desde LS_COLORS (se define más abajo)
eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ──────────────────────────────────────────────────────────────────────────────
# Historial
# ──────────────────────────────────────────────────────────────────────────────
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=10000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
alias history="history 0"

# ──────────────────────────────────────────────────────────────────────────────
# Prompt estilo Kali (con alternativas)
# ──────────────────────────────────────────────────────────────────────────────
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac
force_color_prompt=yes
if [[ -n "$force_color_prompt" ]] && command -v tput >/dev/null && tput setaf 1 >/dev/null 2>&1; then
  color_prompt=yes
fi

configure_prompt() {
  local prompt_symbol=㉿
  case "$PROMPT_ALTERNATIVE" in
    twoline)
      PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n'"$prompt_symbol"$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
      ;;
    oneline)
      PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
      ;;
    backtrack)
      PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n@%m%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
      ;;
  esac
}

# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [[ "$color_prompt" = yes ]]; then
  VIRTUAL_ENV_DISABLE_PROMPT=1
  configure_prompt
else
  PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt() {
  if [[ "$PROMPT_ALTERNATIVE" = oneline ]]; then
    PROMPT_ALTERNATIVE=twoline
  else
    PROMPT_ALTERNATIVE=oneline
  fi
  configure_prompt
  zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# Título de terminal
case "$TERM" in
  xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
esac
precmd() {
  print -Pnr -- "$TERM_TITLE"
  if [[ "$NEWLINE_BEFORE_PROMPT" = yes ]]; then
    if [[ -z "$_NEW_LINE_BEFORE_PROMPT" ]]; then
      _NEW_LINE_BEFORE_PROMPT=1
    else
      print ""
    fi
  fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Colores y alias (ls/grep/less) + fallback si no hay lsd o batcat
# ──────────────────────────────────────────────────────────────────────────────
# Ajuste visual para dirs con 777
export LS_COLORS="$LS_COLORS:ow=30;44:"

# Alias ls con lsd si existe, si no usa ls
if command -v lsd >/dev/null 2>&1; then
  alias ll='lsd -lh --group-dirs=first'
  alias la='lsd -la --group-dirs=first'
  alias l='lsd --group-dirs=first'
  alias lla='lsd -lha --group-dirs=first'
  alias ls='lsd --group-dirs=first'
else
  alias ls='ls --color=auto'
  alias ll='ls -lh'
  alias la='ls -la'
  alias l='ls'
  alias lla='ls -lha'
fi

# cat→batcat si está disponible
if command -v batcat >/dev/null 2>&1; then
  alias cat='batcat'
  alias catnl='batcat --paging=never'
else
  alias catnl='cat'
fi
alias catn='/bin/cat'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Colores para less/man (opcional)
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

# ──────────────────────────────────────────────────────────────────────────────
# PATH (sin duplicar, solo si existen)
# ──────────────────────────────────────────────────────────────────────────────
_addpath() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }
_addpath "$HOME/.local/bin"
_addpath "/usr/lib/python3/dist-packages/impacket"
_addpath "/usr/share/doc/python3-impacket/examples"
_addpath "$HOME/.pdtm/go/bin"
_addpath "$HOME/go/bin"
export PATH

# ──────────────────────────────────────────────────────────────────────────────
# Aliases/funciones personales
# ──────────────────────────────────────────────────────────────────────────────
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# target/cleartarget (genérico, sin usuario hardcodeado)
_target_file="${XDG_CONFIG_HOME:-$HOME/.config}/bin/target/target.txt"
mkdir -p "$(dirname "$_target_file")"
target() {
  local ip_address="$1"
  local machine_name="$2"
  echo "$ip_address $machine_name" > "$_target_file"
}
cleartarget() { : > "$_target_file"; }

# mkt: crea estructura de trabajo
mkt() { mkdir -p nmap content exploits; }

# extractPorts: saca puertos de salida grepable de nmap
extractPorts(){
  local file="$1"
  local ports ip_address
  ports="$(grep -oP '\d{1,5}/open' "$file" | awk -F/ '{print $1}' | xargs | tr ' ' ',')"
  ip_address="$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$file" | sort -u | head -n 1)"
  {
    echo -e "\n[*] Extrayendo Información...\n"
    echo -e "\t[*] Dirección IP: $ip_address"
    echo -e "\t[*] Puertos abiertos: $ports\n"
  } | tee extractPorts.tmp >/dev/null
  if command -v xclip >/dev/null 2>&1; then
    printf %s "$ports" | tr -d '\n' | xclip -sel clip
    echo -e "[*] Puertos copiados al portapapeles\n"
  fi
  cat extractPorts.tmp; rm -f extractPorts.tmp
}

# ──────────────────────────────────────────────────────────────────────────────
# Tema y plugins (orden correcto)
# ──────────────────────────────────────────────────────────────────────────────
# Powerlevel10k (si está instalado)
[[ -f "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
# Config p10k generada por el wizard
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Autosuggestions (OPCIONAL) — debe ir antes del highlighting
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=white,underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
fi
