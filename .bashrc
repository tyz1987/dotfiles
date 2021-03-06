# /etc/bash/bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Change the window title of X terminals 
case ${TERM} in
	xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
		;;
esac

use_color=false

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
	fi

#	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
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

export MOZ_DISABLE_PANGO=1
export EDITOR="vim"

alias dnddir="cd /media/misc1/D"
alias searchinfiles="grep -inr"
alias refreshrepo="sudo repo-add /var/cache/pacman/pkg/custom.db.tar.gz /var/cache/pacman/pkg/*.pkg.tar.xz /var/cache/pacman/pkg/*.pkg.tar.gz"
alias wget="wget -c -t inf"
alias dhistory="less $HOME/dict/dicthistory"
alias rm="rm --verbose"
alias mv="mv --verbose"
alias cp="cp --verbose"
alias p="curl -s -F 'sprunge=<-' http://sprunge.us" 
alias ls="ls -lh --color=auto"
alias hg="hg --verbose"
alias mount="mount -v"
alias grepall="grep --ignore-case --recursive --line-number --with-filename"
alias fullupgrade="yaourt -Syu --noconfirm"
alias onlineapps='lsof -P -i -n | cut -f 1 -d " "| uniq | tail -n +2'
alias diskusage='du -cks * | sort -rn | while read size fname; do for unit in k M G T P E Z Y; do if [ $size -lt 1024 ]; then echo -e "${size}${unit}\t${fname}"; break; fi; size=$((size/1024)); done; done'
alias PROXY="http_proxy=localhost:8118"
findcity() { curl -s "http://api.hostip.info/get_html.php?ip=$1";}
pingallonLAN() { for i in {1..254}; do ping -c 1 10.100.98.$i; done; }
listalliponLAN() { pingallonLAN ; arp -n | grep ether | awk '{print $1}' | sort ;}

findlocation() { place=`echo $1 | sed 's/ /%20/g'` ; curl -s "http://maps.google.com/maps/geo?output=json&oe=utf-8&q=$place" | grep -e "address" -e "coordinates" | sed -e 's/^ *//' -e 's/"//g' -e 's/address/Full Address/';}
makeipaliases() { q=1 ; for i in {220..244}; do sudo ifconfig eth0:$q 10.100.98.$i netmask 255.255.255.0; q=`echo $q+1 | bc`; done ; }

dict() { 
if [ ! -d $HOME/dict ];then 
mkdir $HOME/dict;
fi
cat $HOME/dict/dicthistory | grep " $1$" 1>/dev/null 2>/dev/null;
if [ $? -eq 0 ]
then
	less $HOME/dict/$1;
	return;
fi
	echo `date`" -> ""$1" >> $HOME/dict/dicthistory;
	curl -s "http://www.google.com/dictionary?aq=f&langpair=en|en&q="$1"&hl=en" | html2text -nobs | sed '1,/^ *Dictionary\]/d' | head -n -5 > $HOME/dict/$1;
	stat_data=`stat $HOME/dict/$1 -t | awk '{print $2}'`
	echo -n "Bytes transferred: "
	echo $stat_data
	sleep 1;
	less $HOME/dict/$1;
	echo "::Last searched words.."
	cat $HOME/dict/dicthistory;
}
dictdelete()
{
	rm $HOME/dict/$1;
	cat $HOME/dict/dicthistory | grep -v " $1$" > $HOME/dict/dicthistory.bk;
	mv $HOME/dict/dicthistory.bk $HOME/dict/dicthistory;
	echo ":: Requested item $1 successfully deleted";
}
etymo()
{
curl -s  "http://www.etymonline.com/index.php?term=$1" | html2text -nobs | sed '1,/^.*Z/d' | head -n 7 | less;
}
googl () 
{ 
	curl -s -d "url=${1}" http://goo.gl/api/url | sed -n "s/.*:\"\([^\"]*\).*/\1\n/p" | xclip -i -selection clipboard;
}

? () { echo "$*" | bc -l; }

startvnc()
{
	x11vnc -display :0 -rfbauth ~/.x11vnc/passwd -many -display :0 -bg;
}

# extract function 7z package needed
extract() {
	if [ -f "$1" ] ; then
	case "$1" in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.tar.Z) tar xzf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) 7z x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.jar) 7z x "$1" ;;
		*.tar) tar xf "$1" ;;
		*.tbz2) tar xjf "$1" ;;
		*.tgz) tar xzf "$1" ;;
		*.zip) 7z x "$1" ;;
		*.Z) uncompress "$1" ;;
		*.7z) 7z x "$1" ;;
		*) echo "'$1' cannot be extracted" ;;
		esac
	else
		echo "'$1' is not a file"
			fi
}

wgetsite()
{
	wget --recursive --no-clobber --page-requisites --html-extension --convert-links --domains $1 --no-parent $2;
}

export EDITOR="vim"
export HGUSER="shadyabhi"
HISTSIZE=100000
#DO NOT REMOVE THIS IN ORDER TO HAVE SCRIPT FARM FUNCTIONAL
if [ -f /home/shadyabhi/.scriptfarm/scriptfarm.sh ]; then . /home/shadyabhi/.scriptfarm/scriptfarm.sh ; fi
