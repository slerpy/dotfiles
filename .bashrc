# Shortcut to get the disk size of a directory and contents
sizeof() {
    du -ch "$1" | grep total
}


# Quick d0x: $dox filename.txt
# I would like to tweak this, maybe prompt for another file? and whole dir.
haste()
{
    a=$(cat);
    curl -X POST -s -d "$a" http://hastebin.com/documents |
    awk -F '"' '{print "http://hastebin.com/"$4}';
}

dox()
{
  read -p "Is your IP scrubbed? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cat "$1" | haste
else
  echo "Bounce first."
fi
}


use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dotfiles/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dotfiles/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dotfiles/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dotfiles/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dotfiles/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
	else
# gentoo	PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '
               PS1='\[\033[01;37m\][\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;32m\]\h\[\033[01;37m\]]\[\033[1;37m\]$(__git_ps1) \[\033[01;34m\]\w\[\033[01;37m\] \$\[\033[00m\] '

	fi

#	alias ls='ls --color=auto'
#	alias grep='grep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

# show git states.
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1   # Symbols: unstaged (*) and staged (+)
export GIT_PS1_SHOWSTASHSTATE=1   # Symbol: $
export GIT_PS1_SHOWUNTRACKEDFILES=0   # Symbol: %
