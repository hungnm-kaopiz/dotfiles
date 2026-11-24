#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

INPUT="$(cat)"
[[ -z "${INPUT//[[:space:]]/}" ]] && exit 0

# Dark Tokyo Night truecolor palette (synchronized with agy & codex)
RESET=$'\x1b[0m'
SEP=" "$'\x1b[2m|\x1b[0m'" "
C_MODEL=$'\x1b[38;2;187;154;247m' # #bb9af7 (Purple)
C_META=$'\x1b[38;2;169;177;214m'  # #a9b1d6 (Foreground/Meta)
C_TRACK=$'\x1b[38;2;65;72;104m'   # #414868 (Dim empty bar track)
C_GIT=$'\x1b[38;2;115;218;202m'   # #73daca (Teal)
C_DIRTY=$'\x1b[38;2;255;139;82m'  # #ff8b52 (Orange)
C_CTX=$'\x1b[38;2;122;162;247m'   # #7aa2f7 (Blue)
C_OK=$'\x1b[38;2;158;206;106m'    # #9ece6a (Green)
C_WARN=$'\x1b[38;2;224;175;104m'  # #e0af68 (Yellow)
C_CRIT=$'\x1b[38;2;247;118;142m'  # #f7768e (Red)

NOW_EPOCH="$(date +%s)"

# Single-pass jq extraction & formatting
{
  IFS= read -r MODEL
  IFS= read -r FAST_MODE
  IFS= read -r AGENT_NAME
  IFS= read -r VIM_MODE
  IFS= read -r RAW_CWD
  IFS= read -r CWD_TEXT
  IFS= read -r WORKTREE_HINT
  IFS= read -r PR_NUM
  IFS= read -r PR_URL
  IFS= read -r PR_STATE
  IFS= read -r HAS_CTX
  IFS= read -r CTX_LEVEL
  IFS= read -r CTX_FILLED
  IFS= read -r CTX_EMPTY
  IFS= read -r CTX_INFO
  IFS= read -r HAS_5H
  IFS= read -r FH_LEVEL
  IFS= read -r FH_PCT
  IFS= read -r FH_RESET
  IFS= read -r HAS_WK
  IFS= read -r WK_LEVEL
  IFS= read -r WK_PCT
  IFS= read -r WK_RESET
} < <(jq -r --arg home "$HOME" --argjson now "$NOW_EPOCH" '
  def fmt_pct: (. | round | tostring) + "%";

  # 220K, 1M, 1.5M (no trailing .0)
  def fmt_tokens:
    if . >= 999500 then (((. / 100000) | round) / 10 | tostring) + "M"
    elif . >= 1000 then ((. / 1000) | round | tostring) + "K"
    else (. | round | tostring) end;

  def fmt_reset:
    if . <= 0 then "now"
    else
      ((. / 60) | floor) as $m |
      (($m / 1440) | floor) as $d |
      ((($m % 1440) / 60) | floor) as $h |
      ($m % 60) as $min |
      if $d > 0 then "\($d)d\(if $h > 0 then "\($h)h" else "" end)"
      elif $h > 0 then "\($h)h\(if $min > 0 then "\($min)m" else "" end)"
      else "\([1, $min] | max)m" end
    end;

  def shorten_path($depth):
    if . == "" then ""
    else
      (if . == $home then "~"
       elif startswith($home + "/") then "~" + .[(($home | length)):]
       else . end) as $p |
      if ($p | startswith("~/")) then
        ($p[2:] | split("/") | map(select(length > 0))) as $parts |
        if ($parts | length) <= $depth then $p
        else "~/…/" + ($parts[-$depth:] | join("/")) end
      elif ($p | startswith("/")) then
        ($p[1:] | split("/") | map(select(length > 0))) as $parts |
        if ($parts | length) <= $depth then $p
        else "/…/" + ($parts[-$depth:] | join("/")) end
      else $p end
    end;

  def parse_limit($q):
    if ($q | type) != "object" or ($q.used_percentage == null) then
      ["false", "ok", "", ""]
    else
      (([0, ([100, ($q.used_percentage | tonumber)] | min)] | max)) as $used |
      (if ($q.resets_at // 0) > $now then (($q.resets_at | tonumber) - $now) else 0 end) as $sec |
      (if $used >= 90 then "crit" elif $used >= 70 then "warn" else "ok" end) as $lvl |
      ($used | fmt_pct) as $pct |
      (if $sec > 0 and $used >= 60 then ($sec | fmt_reset) else "" end) as $rst |
      ["true", $lvl, $pct, $rst]
    end;

  ((.model.display_name // .model.id // "Claude") | tostring) as $base_model |
  ((.effort.level // "") | tostring) as $eff |
  (if $eff != "" and (($base_model | ascii_downcase) | contains("(" + ($eff | ascii_downcase) + ")") | not)
   then $base_model + " (" + ($eff[0:1] | ascii_upcase) + ($eff[1:] | ascii_downcase) + ")"
   else $base_model end) as $model |

  $model,
  (if .fast_mode == true then "true" else "false" end),
  ((.agent.name // "") | tostring),
  ((.vim.mode // "") | tostring),
  ((.workspace.current_dir // .cwd // "") | tostring),
  (((.workspace.current_dir // .cwd // "") | tostring) | shorten_path(2)),
  ((.worktree.name // .workspace.git_worktree // "") | tostring),
  ((.pr.number // "") | tostring),
  ((.pr.url // "") | tostring),
  ((.pr.review_state // "") | tostring | ascii_downcase),
  (if (.context_window | type) == "object" then "true" else "false" end),
  (
    if (.context_window | type) == "object" then
      (.context_window.context_window_size // 0) as $size |
      (.context_window.current_usage // {}) as $cu |
      (($cu.input_tokens // 0) + ($cu.cache_creation_input_tokens // 0) + ($cu.cache_read_input_tokens // 0)) as $cu_sum |
      (if .context_window.used_percentage != null then (.context_window.used_percentage | tonumber)
       elif .context_window.remaining_percentage != null then (100 - (.context_window.remaining_percentage | tonumber))
       elif $size > 0 then (($cu_sum * 100) / $size)
       else 0 end) as $pct |
      ([0, ([100, $pct] | min)] | max) as $clamped |
      (if $size > 0 then (($clamped * $size / 100) | round) else $cu_sum end) as $used |
      (($clamped * 12 / 100) | round) as $filled |
      (if $clamped >= 85 then "crit"
       elif $clamped >= 60 then "warn"
       else "ok" end),
      ("▰" * $filled),
      ("▱" * (12 - $filled)),
      (if $size > 0 then ($used | fmt_tokens) + "/" + ($size | fmt_tokens) + " (" + ($clamped | fmt_pct) + ")" else ($clamped | fmt_pct) end)
    else
      "ok", "", "", ""
    end
  ),
  (parse_limit(.rate_limits.five_hour)[]),
  (parse_limit(.rate_limits.seven_day)[] )
' <<< "$INPUT")

# Row 1 assembly
# PR: "PR #N" stays meta (clickable), "(state)" colored by meaning
render_pr() {
  local t="$1" link state col
  if [[ "$t" =~ ^(.*)\ \(([a-z_]+)\)$ ]]; then
    link="${BASH_REMATCH[1]}"; state="${BASH_REMATCH[2]}"
  else
    link="$t"; state=""
  fi
  case "$state" in
    open|approved)     col="$C_OK" ;;
    changes_requested) col="$C_WARN" ;;
    closed)            col="$C_CRIT" ;;
    merged)            col="$C_MODEL" ;;
    *)                 col="$C_META" ;;
  esac
  printf '%s' "${C_META}${link}${RESET}"
  [[ -n "$state" ]] && printf '%s' " ${col}(${state})${RESET}"
  return 0
}

ROW1_PARTS=()

if [[ -n "$MODEL" ]]; then
  ROW1_PARTS+=("${C_MODEL}${MODEL}${RESET}")
fi

# CWD right after the model: underlined + OSC 8 file:// hyperlink so terminals
# (Ghostty: Ctrl+click) show it as clickable and open the full path.
url_encode_path() {
  local s="$1" out="" c i
  for (( i = 0; i < ${#s}; i++ )); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9/._~-]) out+="$c" ;;
      *) out+="$(printf '%%%02X' "'$c")" ;;
    esac
  done
  printf '%s' "$out"
}

if [[ -n "$CWD_TEXT" ]]; then
  if [[ -n "$RAW_CWD" ]]; then
    CWD_LINK=$'\x1b]8;;file://'"$(url_encode_path "$RAW_CWD")"$'\x1b\\'"${CWD_TEXT}"$'\x1b]8;;\x1b\\'
    ROW1_PARTS+=("${C_CTX}"$'\x1b[4m'"${CWD_LINK}${RESET}")
  else
    ROW1_PARTS+=("${C_META}${CWD_TEXT}${RESET}")
  fi
fi

if [[ "$FAST_MODE" == "true" ]]; then
  ROW1_PARTS+=("${C_WARN}fast${RESET}")
fi

PARENT_ARGS="$(ps -o args= -p "$PPID" 2>/dev/null || true)"
if [[ "$PARENT_ARGS" == *"--dangerously-skip-permissions"* || "$PARENT_ARGS" == *"bypassPermissions"* ]]; then
  ROW1_PARTS+=("${C_CRIT}bypass${RESET}")
fi

# Bounded command runner + stale-while-revalidate Git cache (3s TTL per CWD)
run_with_timeout() {
  local sec="$1"; shift
  perl -e 'alarm shift; exec @ARGV' "$sec" "$@"
}

# Portable file mtime (BSD stat on macOS, GNU stat on Linux)
mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

hash16() {
  local h
  if [[ -x /sbin/md5 ]]; then
    h="$(/sbin/md5 -qs "$1")"
  else
    h="$(printf '%s' "$1" | { shasum -a 256 2>/dev/null || sha256sum; })"
  fi
  printf '%s' "${h:0:16}"
}

refresh_git_cache() {
  local cwd="$1" cache_file="$2" tmp_file="${2}.$$.tmp"
  local porcelain rc=0 oid="" head="" upstream="" branch="" dirty="false"
  local op="" sync="" wt="" added="0" removed="0" has_remote="false"
  local git_dir="" common_dir="" line ab ahead_raw behind_raw ahead behind

  porcelain="$(run_with_timeout 3 git --no-optional-locks -C "$cwd" status --porcelain=v2 --branch -uno 2>/dev/null)" || rc=$?
  if (( rc == 142 )); then
    return 0
  fi
  if (( rc != 0 )) || [[ -z "$porcelain" ]]; then
    printf '0\n\nfalse\n\n\n\n0\n0\nfalse\n' > "$tmp_file" && mv -f "$tmp_file" "$cache_file"
    return 0
  fi

  while IFS= read -r line; do
    case "$line" in
      "# branch.oid "*)      oid="${line#\# branch.oid }" ;;
      "# branch.head "*)     head="${line#\# branch.head }" ;;
      "# branch.upstream "*) upstream="${line#\# branch.upstream }" ;;
      "# branch.ab "*)
        ab="${line#\# branch.ab }"
        read -r ahead_raw behind_raw <<< "$ab"
        ahead="${ahead_raw#+}"
        behind="${behind_raw#-}"
        local sync_parts=()
        (( ${ahead:-0} > 0 )) && sync_parts+=("⇡${ahead}")
        (( ${behind:-0} > 0 )) && sync_parts+=("⇣${behind}")
        (( ${#sync_parts[@]} > 0 )) && sync=" ${sync_parts[*]}"
        ;;
      "#"*|"") ;;
      *) dirty="true" ;;
    esac
  done <<< "$porcelain"

  if [[ "$head" == "(detached)" ]]; then
    [[ -n "$oid" && "$oid" != "(initial)" ]] && branch="${oid:0:7}"
  elif [[ -n "$head" ]]; then
    branch="$head"
  fi

  if [[ -z "$branch" ]]; then
    printf '0\n\nfalse\n\n\n\n0\n0\nfalse\n' > "$tmp_file" && mv -f "$tmp_file" "$cache_file"
    return 0
  fi

  {
    IFS= read -r git_dir || true
    IFS= read -r common_dir || true
  } < <(run_with_timeout 2 git --no-optional-locks -C "$cwd" rev-parse --git-dir --git-common-dir 2>/dev/null || true)

  if [[ -n "$git_dir" ]]; then
    [[ "$git_dir" != /* ]] && git_dir="$cwd/$git_dir"
    if [[ "$git_dir" == *"/worktrees/"* ]]; then
      wt="${git_dir##*/worktrees/}"
      wt="${wt%%/*}"
    fi
    if [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]; then
      op=" REBASE"
    elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
      op=" MERGING"
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
      op=" CHERRY-PICKING"
    elif [[ -f "$git_dir/BISECT_LOG" ]]; then
      op=" BISECTING"
    fi
  fi

  if [[ -n "$upstream" ]]; then
    has_remote="true"
  else
    [[ -z "$common_dir" ]] && common_dir="$git_dir"
    [[ -n "$common_dir" && "$common_dir" != /* ]] && common_dir="$cwd/$common_dir"
    if [[ -n "$common_dir" && -f "$common_dir/config" ]] && grep -q '^\[remote ' "$common_dir/config" 2>/dev/null; then
      has_remote="true"
    fi
  fi

  if [[ "$dirty" == "true" && "$oid" != "(initial)" ]]; then
    read -r added removed < <(
      (run_with_timeout 2 git --no-optional-locks -C "$cwd" diff HEAD --numstat 2>/dev/null || true) |
        awk '{ if ($1 ~ /^[0-9]+$/) a += $1; if ($2 ~ /^[0-9]+$/) r += $2 } END { printf "%d %d\n", a, r }'
    )
  fi

  printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
    "1" "$branch" "$dirty" "$op" "$sync" "$wt" "${added:-0}" "${removed:-0}" "$has_remote" \
    > "$tmp_file" && mv -f "$tmp_file" "$cache_file"
}

# Git & Worktree & Operation & Diff & PR
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
BRANCH=""
RAW_BRANCH=""
GIT_WORKTREE="$WORKTREE_HINT"
GIT_CHANGES=""
GIT_SYNC=""
GIT_OP=""
DIRTY="false"
GIT_HAS_REMOTE="false"
if [[ -n "$RAW_CWD" && -d "$RAW_CWD" ]]; then
  mkdir -p "$CACHE_DIR"
  GIT_CACHE_FILE="$CACHE_DIR/git-$(hash16 "$RAW_CWD")"
  NEED_GIT_REFRESH="false"
  COLD_GIT="false"
  if [[ -f "$GIT_CACHE_FILE" ]]; then
    GIT_MTIME="$(mtime "$GIT_CACHE_FILE" || echo 0)"
    if (( NOW_EPOCH - GIT_MTIME >= 3 )); then
      NEED_GIT_REFRESH="true"
    fi
  else
    NEED_GIT_REFRESH="true"
    COLD_GIT="true"
  fi
  if [[ "$NEED_GIT_REFRESH" == "true" ]]; then
    touch "$GIT_CACHE_FILE"
    ( refresh_git_cache "$RAW_CWD" "$GIT_CACHE_FILE" ) </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null || true
    if [[ "$COLD_GIT" == "true" ]]; then
      for _ in 1 2 3 4 5 6 7 8; do
        [[ -s "$GIT_CACHE_FILE" ]] && break
        sleep 0.025
      done
    fi
  fi
  if [[ -s "$GIT_CACHE_FILE" ]]; then
    IS_GIT="0"
    CACHED_BRANCH=""
    CACHED_DIRTY="false"
    CACHED_OP=""
    CACHED_SYNC=""
    CACHED_WT=""
    ADDED="0"
    REMOVED="0"
    CACHED_REMOTE="false"
    {
      IFS= read -r IS_GIT || true
      IFS= read -r CACHED_BRANCH || true
      IFS= read -r CACHED_DIRTY || true
      IFS= read -r CACHED_OP || true
      IFS= read -r CACHED_SYNC || true
      IFS= read -r CACHED_WT || true
      IFS= read -r ADDED || true
      IFS= read -r REMOVED || true
      IFS= read -r CACHED_REMOTE || true
    } < "$GIT_CACHE_FILE"
    if [[ "$IS_GIT" == "1" && -n "$CACHED_BRANCH" ]]; then
      BRANCH="$CACHED_BRANCH"
      RAW_BRANCH="$CACHED_BRANCH"
      DIRTY="$CACHED_DIRTY"
      GIT_OP="$CACHED_OP"
      GIT_SYNC="$CACHED_SYNC"
      [[ -z "$GIT_WORKTREE" && -n "$CACHED_WT" ]] && GIT_WORKTREE="$CACHED_WT"
      GIT_HAS_REMOTE="$CACHED_REMOTE"
      CHANGE_PARTS=()
      (( ${ADDED:-0} > 0 )) && CHANGE_PARTS+=("${C_OK}+${ADDED}")
      (( ${REMOVED:-0} > 0 )) && CHANGE_PARTS+=("${C_CRIT}−${REMOVED}")
      if (( ${#CHANGE_PARTS[@]} > 0 )); then
        IFS=' ' eval 'GIT_CHANGES="${C_GIT}${CHANGE_PARTS[*]}${RESET}"'
      fi
    fi
  fi
fi

if [[ -n "$BRANCH" ]]; then
  if (( ${#BRANCH} > 28 )); then
    BRANCH="${BRANCH:0:27}…"
  fi
  DIRTY_MARK=""
  [[ "$DIRTY" == "true" ]] && DIRTY_MARK="${C_DIRTY}*"
  OP_MARK=""
  [[ -n "$GIT_OP" ]] && OP_MARK="${C_DIRTY}${GIT_OP}"
  SYNC_MARK=""
  [[ -n "$GIT_SYNC" ]] && SYNC_MARK="${C_GIT}${GIT_SYNC}"
  ROW1_PARTS+=("${C_GIT}${BRANCH}${DIRTY_MARK}${OP_MARK}${SYNC_MARK}${RESET}")
fi

if [[ -n "$GIT_WORKTREE" ]]; then
  ROW1_PARTS+=("${C_GIT}${GIT_WORKTREE}${RESET}")
fi

if [[ -n "$GIT_CHANGES" ]]; then
  ROW1_PARTS+=("$GIT_CHANGES")
fi

# PR hyperlink: prefer built-in .pr if available, else stale-while-revalidate gh pr view cache
if [[ -n "$PR_NUM" && -n "$PR_URL" ]]; then
  PR_LINK=$'\x1b]8;;'"${PR_URL}"$'\x1b\\'"PR #${PR_NUM}"$'\x1b]8;;\x1b\\'
  [[ -n "$PR_STATE" ]] && PR_LINK="${PR_LINK} (${PR_STATE})"
  ROW1_PARTS+=("$(render_pr "$PR_LINK")")
elif [[ "$GIT_HAS_REMOTE" == "true" && -n "$RAW_BRANCH" && -n "$RAW_CWD" && -d "$RAW_CWD" ]] && command -v gh >/dev/null 2>&1; then
  mkdir -p "$CACHE_DIR"
  CWD_HASH="$(hash16 "${RAW_CWD}:${RAW_BRANCH}")"
  CACHE_FILE="$CACHE_DIR/pr-${CWD_HASH}"
  PR_TEXT=""
  NEED_REFRESH="false"
  if [[ -f "$CACHE_FILE" ]]; then
    PR_TEXT="$(cat "$CACHE_FILE" 2>/dev/null || true)"
    FILE_MTIME="$(mtime "$CACHE_FILE" || echo 0)"
    if (( NOW_EPOCH - FILE_MTIME >= 30 )); then
      NEED_REFRESH="true"
    fi
  else
    NEED_REFRESH="true"
  fi
  if [[ "$NEED_REFRESH" == "true" ]]; then
    # Touch first to prevent refresh stampedes while gh is in flight
    touch "$CACHE_FILE"
    (
      TMP_FILE="${CACHE_FILE}.$$.tmp"
      if NEW_PR="$(cd "$RAW_CWD" && run_with_timeout 3 gh pr view --json number,state,url --jq '"\u001b]8;;\(.url)\u001b\\PR #\(.number)\u001b]8;;\u001b\\ (\(.state | ascii_downcase))"' 2>&1)"; then
        printf '%s' "$NEW_PR" > "$TMP_FILE" && mv -f "$TMP_FILE" "$CACHE_FILE"
      elif [[ "$NEW_PR" == *"no pull requests found"* ]]; then
        : > "$TMP_FILE" && mv -f "$TMP_FILE" "$CACHE_FILE"
      fi
    ) </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null || true
  fi
  if [[ -n "$PR_TEXT" ]]; then
    ROW1_PARTS+=("$(render_pr "$PR_TEXT")")
  fi
fi

# Transient / dynamic state at the far right so CWD & branch never jump horizontally
if [[ -n "$AGENT_NAME" ]]; then
  ROW1_PARTS+=("${C_META}agent: ${AGENT_NAME}${RESET}")
fi

if [[ -n "$VIM_MODE" ]]; then
  ROW1_PARTS+=("${C_META}${VIM_MODE}${RESET}")
fi

# Row 2 assembly
ROW2_PARTS=()

if [[ "$HAS_CTX" == "true" ]]; then
  case "$CTX_LEVEL" in
    crit) C_CUR_CTX="$C_CRIT" ;;
    warn) C_CUR_CTX="$C_WARN" ;;
    *)    C_CUR_CTX="$C_CTX" ;;
  esac
  ROW2_PARTS+=("${C_META}Context: ${C_CUR_CTX}${CTX_FILLED}${C_TRACK}${CTX_EMPTY}${RESET} ${C_CUR_CTX}${CTX_INFO}${RESET}")
fi

if [[ "$HAS_5H" == "true" ]]; then
  case "$FH_LEVEL" in
    crit) C_CUR_FH="$C_CRIT" ;;
    warn) C_CUR_FH="$C_WARN" ;;
    *)    C_CUR_FH="$C_OK" ;;
  esac
  FH_RST_STR=""
  [[ -n "$FH_RESET" ]] && FH_RST_STR=" (${FH_RESET})"
  ROW2_PARTS+=("${C_META}5h: ${C_CUR_FH}${FH_PCT}${FH_RST_STR}${RESET}")
fi

if [[ "$HAS_WK" == "true" ]]; then
  case "$WK_LEVEL" in
    crit) C_CUR_WK="$C_CRIT" ;;
    warn) C_CUR_WK="$C_WARN" ;;
    *)    C_CUR_WK="$C_OK" ;;
  esac
  WK_RST_STR=""
  [[ -n "$WK_RESET" ]] && WK_RST_STR=" (${WK_RESET})"
  ROW2_PARTS+=("${C_META}wk: ${C_CUR_WK}${WK_PCT}${WK_RST_STR}${RESET}")
fi

join_parts() {
  local sep="$1"
  shift
  local first=1
  for part in "$@"; do
    if (( first )); then
      printf '%s' "$part"
      first=0
    else
      printf '%s%s' "$sep" "$part"
    fi
  done
}

if (( ${#ROW1_PARTS[@]} > 0 )); then
  join_parts "$SEP" "${ROW1_PARTS[@]}"
  printf '\n'
fi

if (( ${#ROW2_PARTS[@]} > 0 )); then
  join_parts "$SEP" "${ROW2_PARTS[@]}"
  printf '\n'
fi
