# Cache the output of commands that only depend on their binary and arguments
# (shell init scripts, completions), so startup doesn't run them every time.
#
#   _zsh_cmd_cache [-d <dep>]... <file> <command> [args...]
#
# Writes the command's output to <file> and returns 0 once it is there. The
# command runs again only when its binary or a -d dependency (e.g. a config file
# the output depends on) is newer, the binary resolves to another path, or the
# arguments change (kept in <file>.cmd). Sets REPLY to "new" when it just
# (re)generated the file, "cached" otherwise. Returns 1 if the command is
# missing, fails or prints nothing; an older cached file is then kept.
# Not for output that embeds the current environment (`mise activate` bakes in
# $PATH).
_zsh_cmd_cache() {
  local -a deps
  while [[ $1 == -d ]]; do deps+=($2); shift 2; done
  local out=$1; shift
  local bin=${commands[$1]}
  REPLY=
  [[ -n $bin ]] || return 1

  local stamp="$bin ${(j: :)${(q)@[2,-1]}}" line=
  local dep fresh=1
  for dep in $bin $deps; do [[ $dep -nt $out ]] && fresh=0; done
  if (( fresh )) && [[ -s $out && -r $out.cmd ]]; then
    read -r line < $out.cmd
    [[ $line == $stamp ]] && { REPLY=cached; return 0 }
  fi

  mkdir -p ${out:h}
  local tmp=$out.$$
  if "$@" >| $tmp 2>/dev/null && [[ -s $tmp ]]; then
    mv -f $tmp $out && print -r -- $stamp >| $out.cmd
    REPLY=new
    return 0
  fi
  rm -f $tmp
  return 1
}

_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# A tool's init script through the cache:
#   _zsh_cached_init [-d <dep>]... <tool> [args...] && source $_zsh_init
# The caller sources it at top level: inside a function, its typeset/local
# variables would not outlive the call.
_zsh_cached_init() {
  local -a deps
  while [[ $1 == -d ]]; do deps+=($1 $2); shift 2; done
  _zsh_init="$_zsh_cache_dir/init/$1.zsh"
  _zsh_cmd_cache $deps "$_zsh_init" "$@"
}
