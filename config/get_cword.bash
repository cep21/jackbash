# This part taken from https://code.google.com/p/bash-completion-lib/source/browse/trunk/include/_get_cword?spec=svn85&r=85
# Get the word to complete
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# it will complete just "foo", not "foobar", which is what the user wants.)
#
# Accepts an optional parameter indicating which characters out of
# $COMP_WORDBREAKS should NOT be considered word breaks. This is useful
# for things like scp where we want to return host:path and not only path.
_get_cword()
{
	local i
	local WORDBREAKS=${COMP_WORDBREAKS}
	if [ -n $1 ]; then
		for (( i=0; i<${#1}; ++i )); do
			local char=${1:$i:1}
			WORDBREAKS=${WORDBREAKS//$char/}
		done
	fi
	local cur=${COMP_LINE:0:$COMP_POINT}
	local tmp="${cur}"
	local word_start=`expr "$tmp" : '.*['"${WORDBREAKS}"']'`
	while [ "$word_start" -ge 2 ]; do
        	local char=${cur:$(( $word_start - 2 )):1}
		if [ "$char" != "\\" ]; then
			break
		fi
		tmp=${COMP_LINE:0:$(( $word_start - 2 ))}
		word_start=`expr "$tmp" : '.*['"${WORDBREAKS}"']'`
	done


	cur=${cur:$word_start}
	echo $cur
} # _get_cword()


