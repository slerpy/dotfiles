# i mean, obviously...
function cheat() {
      curl cht.sh/$1
}


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

# whois query...
function whois() {
	local domain=$(echo "$1" | awk -F/ '{print $3}') # get domain from URL
	if [ -z $domain ] ; then
		domain=$1
	fi
	echo "Getting whois record for: $domain …"

	# avoid recursion
	# strip extra fluff
	/usr/bin/whois -h whois.internic.net $domain | sed '/NOTICE:/q'
}

# gif like its 2005, needs ffmpeg and gifsicle
gifify() {
  if [[ -n "$1" ]]; then
	if [[ $2 == '--good' ]]; then
	  ffmpeg -i "$1" -r 10 -vcodec png out-static-%05d.png
	  time convert -verbose +dither -layers Optimize -resize 900x900\> out-static*.png  GIF:- | gifsicle --colors 128 --delay=5 --loop --optimize=3 --multifile - > "$1.gif"
	  rm -f out-static*.png
	else
	  ffmpeg -i "$1" -s 600x400 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "$1.gif"
	fi
  else
	echo "proper usage: gifify <input_movie.mov>. You DO need to include extension."
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
