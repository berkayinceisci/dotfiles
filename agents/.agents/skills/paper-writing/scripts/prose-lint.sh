#!/bin/bash
#
# prose-lint.sh: flag the word-level patterns the lab's polish commits removed.
#
# Usage: prose-lint.sh [-v] [-s] [-c cat1,cat2,...] file.tex ...
#   -v  log the chosen categories and each grep pattern to stderr
#   -s  print only the per-category summary counts
#   -c  restrict to the listed categories (default: all)
#
# Categories:
#   weasel       Matt Might weasel words and the intensifier/hedge adverbs
#   passive      passive voice (Might's regex)
#   opener       sentence openers that announce instead of state
#   negpar       negative parallelism: ", not X", "rather than", "not X but Y"
#   cleft        reveal constructions: "What fails is", "The reason is that",
#                "It is the X that"
#   emdash       --- or a Unicode em dash in prose
#   middot       a middle dot or bullet used as a separator between words
#                (U+00B7, U+2022, \textperiodcentered, $\cdot$ between words)
#   metaphor     the metaphor families the polish passes removed
#   jargon       lab-internal vocabulary (arm, campaign, cell, probe, ...)
#   hype         novelty and over-claim words, absolutes
#   slop         standard LLM tells never allowed in the papers
#   figshows     "Figure N shows that" and "We can observe that" framings
#   question     rhetorical questions in prose
#   colon        mid-sentence explanatory colons (lowercase continuation)
#   semicolon    semicolons joining clauses in prose
#   range        numeric ranges written "N to M" instead of "N--M"
#   onlyafter    "only" placed after the verb it limits
#   incomment    a LaTeX comment line inside a paragraph (next line is body text)
#   longsent     sentences over 40 words
#   twins        adjacent \item lines, or consecutive sentences, that open with
#                the same three words (matched openers)
#
# Every hit is a prompt for a human read, not a verdict. Each match prints as
# file:line: matched text. LaTeX comments are stripped before matching.
#
# Lists come from asplos27-allochar bin/weasel.sh and bin/passive.sh (Might),
# and from the polish diffs of allochar, cxlssd, dst, epic, and tierce.

set -euo pipefail

verbose=0
summary=0
cats="weasel,passive,opener,negpar,cleft,emdash,middot,metaphor,jargon,hype,slop,figshows,question,colon,semicolon,range,onlyafter,incomment,longsent,twins"
maxwords=40

usage() {
  sed -n '2,39p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

while getopts "vsc:" opt; do
  case "$opt" in
    v) verbose=1 ;;
    s) summary=1 ;;
    c) cats="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[[ $# -ge 1 ]] || usage

log() { if [[ $verbose -eq 1 ]]; then echo "[prose-lint] $*" >&2; fi; }

weasel='many|various|very|fairly|several|extremely|exceedingly|quite|remarkably|few|surprisingly|mostly|largely|huge|tiny|((are|is) a number)|excellent|interestingly|significantly|substantially|clearly|vast|relatively|completely|actually|exactly|genuinely|merely|essentially|precisely|quietly|silently|simply|nevertheless|more importantly|vastly|explicitly|especially|accurately|massively|fundamentally|easily|seamlessly|by design|crucially|obviously|notably|importantly|dramatically|drastically|highly|truly|really|arguably|undoubtedly'

irregulars='awoken|been|born|beat|become|begun|bent|beset|bet|bid|bidden|bound|bitten|bled|blown|broken|bred|brought|broadcast|built|burnt|burst|bought|cast|caught|chosen|clung|come|cost|crept|cut|dealt|dug|dived|done|drawn|dreamt|driven|drunk|eaten|fallen|fed|felt|fought|found|fit|fled|flung|flown|forbidden|forgotten|foregone|forgiven|forsaken|frozen|gotten|given|gone|ground|grown|hung|heard|hidden|hit|held|hurt|kept|knelt|knit|known|laid|led|leapt|learnt|left|lent|let|lain|lighted|lost|made|meant|met|misspelt|mistaken|mown|overcome|overdone|overtaken|overthrown|paid|pled|proven|put|quit|read|rid|ridden|rung|risen|run|sawn|said|seen|sought|sold|sent|set|sewn|shaken|shaven|shorn|shed|shone|shod|shot|shown|shrunk|shut|sung|sunk|sat|slept|slain|slid|slung|slit|smitten|sown|spoken|sped|spent|spilt|spun|spit|split|spread|sprung|stood|stolen|stuck|stung|stunk|stridden|struck|strung|striven|sworn|swept|swollen|swum|swung|taken|taught|torn|told|thought|thrived|thrown|thrust|trodden|understood|upheld|upset|woken|worn|woven|wed|wept|wound|won|withheld|withstood|wrung|written'
passive="\\b(am|are|were|being|is|been|was|be)\\b[ ]*(\\w+ed|($irregulars))\\b"

opener='(^|[.!?:] +)(Thus|Consequently|However|Together|Overall|In sum|In summary|In conclusion|Moreover|Furthermore|Additionally|Conversely|Note that|That is|In other words|In particular|Here|In this paper|This paper (makes|presents|proposes)|Our key insight|The key (question|insight|idea) is|It is worth noting|It is important to note|Two (responses|terms|points) (follow|recur)|Crucially|Notably|Importantly|Interestingly|More strikingly|Ultimately|Taken together|To this end|In light of|At its core|First and foremost),?\b'

negpar=',[ ]*not (a|an|the|from|to|of|in|on|by|its|their|our|one|just|merely|only|[a-z]+ing)\b|\brather than\b|\bnot ([a-z]+ ){1,4}but( rather)? [a-z]|\binstead of\b|\bis not (a|an) [a-z]+, (it|but) (is|a)'

cleft='\b(What (fails|matters|changes|differs|remains|breaks|works|happens|follows|counts|holds|is (lost|missing|new|different)) (here |instead |then )?(is|was)\b|It (is|was) (the|a|an|this|these|those|not) [^,.]{1,40} (that|which|who)\b|The (reason|problem|point|difference|key|issue|question|answer|catch|trick|cost) (here |then )?(is|was) (that|whether|not)\b|\b(is|are) what (makes|lets|keeps|allows|breaks)\b)'

emdash='---|—'

middot='·|•|\\textperiodcentered|\\textbullet|[a-zA-Z)}] *\$\\cdot\$ *[a-zA-Z({]'

metaphor='\b(walls?|prices?|priced|pricing|tax(es)?|levers?|subsid(y|ies)|gifts?|currenc(y|ies)|bills?|bargains?|purchases?|bets?|meters?|crowds?|funnels?|starv(e|es|ed|ing|ation)|bridges?|patchwork|emptier|quietly|silently|pulled|buys|wants? the|trusts? no|visually appealing|beyond the reach|turns? out to be|harder than it looks|all along|the elephant|double-edged|silver bullet|low-hanging)\b'

jargon='\b(arms?|campaigns?|cells?|probes?|interventions?|workers?|census|process blocks?|block-to-block|bears? on|bearing on|gated?|gating|fixed (the|in|by) |fixes the|retained (record|cells?)|surviving record|proxy falsification|pooling|churn|Device truth|Channel [A-C]|gmean|three-arm|Finding #?[0-9]|Challenge [0-9])\b'

hype='\b(novel|the first|first-ever|no existing|state-of-the-art|SOTA|guarantees?|perfect(ly)?|exact(ly)?|undocumented|fundamentally|essential(ly)? to|unlock(s|ing)?|fully (exploit|leverage)|all (workloads|cases|systems)|always|never fails|dramatic(ally)?|orders? of magnitude|huge|massive|unprecedented|superior|outperforms all|significantly (outperform|improve)s?|demonstrates? that|establishes? that|proves? that|clearly (shows?|demonstrates?)|key (insight|enabler|priorit(y|ies)))\b'

slop='\b(delv(e|es|ing)|leverag(e|es|ed|ing)|utiliz(e|es|ed|ing)|facilitat(e|es|ed|ing)|robust(ly|ness)?|seamless(ly)?|paradigm|harness(es|ed|ing)?|landscape|crucial(ly)?|pivotal|holistic(ally)?|showcas(e|es|ing)|underscor(e|es|ing)|highlights? the|testament|game-chang(er|ing)|cutting-edge|comprehensive(ly)?|multifaceted|myriad|tapestry|realm|foster(s|ed|ing)?|navigat(e|es|ing)|streamlin(e|es|ed|ing)|revolutioniz(e|es|ing)|transformative|groundbreaking|intricate|nuanced|meticulous(ly)?|elevat(e|es|ing)|empower(s|ed|ing)?|embark|journey|ensur(e|es|ing) that|plays? a (crucial|key|vital|critical) role|serves? as|stands? as|sheds? light|offers? a glimpse|paves? the way|opens? the door|not only [^.]{1,60} but also|a wide range of|in today'"'"'s|it is worth noting|it is important to note|in the realm of|tedious and error-prone|at scale|a plethora of)\b'

figshows='\b((Figure|Fig\.|Table|Section)~?\\?(ref|autoref)?\{?[^} ]*\}? (shows|demonstrates|illustrates|reveals|confirms|highlights) that|(We|we|One|one) can (observe|see) that|As (shown|illustrated|depicted) in [^,]{1,40}, (we|it) (can|observe|see)|It can be (seen|observed) that|As can be seen)\b'

question='\?[ ]*$|\?[ ]+[A-Z]|\?\}'

# a colon followed by a lowercase word inside running text; list and
# definition colons before a LaTeX environment or a capitalized item are
# left alone
colon='[a-z0-9)}%]: +[a-z$]'

# a semicolon between clauses in running text (a colon in disguise)
semicolon='[a-z0-9)}%]; +[a-z\\$]'

# a numeric range spelled with "to" (digits, labels like H1 or P5, or number
# words on both sides);
# "from N to M" along an axis is a judgment call, review by hand
range='\b([A-Z]{0,2}[0-9]+(\.[0-9]+)?|one|two|three|four|five|six|eight|ten|twelve|sixteen)(\\,)?[A-Za-z%$\\]* to ([A-Z]{0,2}[0-9]+(\.[0-9]+)?|one|two|three|four|five|six|eight|ten|twelve|sixteen|thirty|sixty)\b'

# "only" after a verb: requests only, recovers only, is only, can only
# (-ing forms left out, "tiering only pays" is a noun subject)
onlyafter='\b([a-z]+(s|es|ed)|is|are|was|were|be|can|could|has|have|had|does|did|will|would|may|must) only\b'

strip_tex() {
  # drop full-line and trailing comments, keep escaped percent signs
  sed -e 's/^%.*$//' -e 's/\([^\\]\)%.*$/\1/' "$1"
}

# a full-line comment whose next line is body text sits inside a paragraph;
# one rewrap can pull the following sentence onto the comment line
in_paragraph_comments() {
  local file="$1" out
  log "category=incomment file=$file"
  # only body text counts: a line opening with a letter, digit, quote or math,
  # not a macro line (\section, \usepackage, \item) or a blank line
  if out="$(awk 'prev ~ /^[[:space:]]*%/ && $0 ~ /^[[:space:]]*[A-Za-z0-9`$(]/ {print NR": "$0} {prev=$0}' "$file")" && [[ -n "$out" ]]; then
    local n
    n=$(printf '%s\n' "$out" | wc -l)
    counts["incomment"]=$(( ${counts["incomment"]:-0} + n ))
    printf '%s\n' "$out" | sed "s|^|$file:|; s|\$| [incomment]|"
  fi
}

run_grep() {
  local cat="$1" pat="$2" file="$3"
  log "category=$cat file=$file pattern=$pat"
  local out
  # grep returns 1 on no match; that is a query result, not an error
  if out="$(strip_tex "$file" | grep -n -i -o -E ".{0,40}($pat).{0,40}" 2>/dev/null)"; then
    local n
    n=$(printf '%s\n' "$out" | wc -l)
    counts["$cat"]=$(( ${counts["$cat"]:-0} + n ))
    if [[ $summary -eq 0 ]]; then
      printf '%s\n' "$out" | sed "s|^|$file:|; s|$| [$cat]|"
    fi
  fi
}

long_sentences() {
  local file="$1"
  log "category=longsent file=$file maxwords=$maxwords"
  local out
  # join the paragraph, split on sentence terminators followed by whitespace
  # and a capital or a LaTeX command, count words, report over the limit
  if out="$(strip_tex "$file" | tr '\n' ' ' | sed -E 's/([.!?])[ ]+([A-Z\\])/\1\n\2/g' |
    awk -v max="$maxwords" 'NF > max { printf "%d words: %s\n", NF, substr($0, 1, 120) }')"; then
    if [[ -n "$out" ]]; then
      local n
      n=$(printf '%s\n' "$out" | wc -l)
      counts["longsent"]=$(( ${counts["longsent"]:-0} + n ))
      if [[ $summary -eq 0 ]]; then
        printf '%s\n' "$out" | sed "s|^|$file: |; s|$| [longsent]|"
      fi
    fi
  fi
}

# first three alphabetic words of a line or sentence, lowercased, LaTeX
# commands dropped; empty when fewer than three words
twins_key='function key(s,    n, w) {
  gsub(/\\[a-zA-Z]+(\[[^]]*\])?/, " ", s)
  gsub(/[^a-zA-Z ]/, " ", s)
  n = split(tolower(s), w, " ")
  if (n < 3) return ""
  return w[1] " " w[2] " " w[3]
}'

twins() {
  local file="$1"
  log "category=twins file=$file"
  local out
  # pass 1: consecutive \item lines (a blank line resets the comparison)
  # pass 2: consecutive sentences, split as in long_sentences
  if out="$({
    strip_tex "$file" | awk "$twins_key"'
      /^[ \t]*\\item/ {
        k = key($0)
        if (k != "" && k == pk) printf "items: %s / %s\n", substr(p, 1, 60), substr($0, 1, 60)
        pk = k; p = $0; next
      }
      /^[ \t]*$/ { pk = "" }'
    strip_tex "$file" | tr '\n' ' ' | sed -E 's/([.!?])[ ]+([A-Z\\])/\1\n\2/g' | awk "$twins_key"'
      {
        k = key($0)
        if (k != "" && k == pk) printf "sentences: %s / %s\n", substr(p, 1, 60), substr($0, 1, 60)
        pk = k; p = $0
      }'
  })"; then
    if [[ -n "$out" ]]; then
      local n
      n=$(printf '%s\n' "$out" | wc -l)
      counts["twins"]=$(( ${counts["twins"]:-0} + n ))
      if [[ $summary -eq 0 ]]; then
        printf '%s\n' "$out" | sed "s|^|$file: |; s|$| [twins]|"
      fi
    fi
  fi
}

declare -A counts
IFS=',' read -r -a catlist <<< "$cats"
log "categories: ${catlist[*]}"

for file in "$@"; do
  [[ -f "$file" ]] || { echo "prose-lint: no such file: $file" >&2; exit 1; }
  for cat in "${catlist[@]}"; do
    case "$cat" in
      weasel)   run_grep weasel   "\\b($weasel)\\b" "$file" ;;
      passive)  run_grep passive  "$passive" "$file" ;;
      opener)   run_grep opener   "$opener" "$file" ;;
      negpar)   run_grep negpar   "$negpar" "$file" ;;
      cleft)    run_grep cleft    "$cleft" "$file" ;;
      emdash)   run_grep emdash   "$emdash" "$file" ;;
      middot)   run_grep middot   "$middot" "$file" ;;
      metaphor) run_grep metaphor "$metaphor" "$file" ;;
      jargon)   run_grep jargon   "$jargon" "$file" ;;
      hype)     run_grep hype     "$hype" "$file" ;;
      slop)     run_grep slop     "$slop" "$file" ;;
      figshows) run_grep figshows "$figshows" "$file" ;;
      question) run_grep question "$question" "$file" ;;
      colon)    run_grep colon    "$colon" "$file" ;;
      semicolon) run_grep semicolon "$semicolon" "$file" ;;
      range)    run_grep range    "$range" "$file" ;;
      onlyafter) run_grep onlyafter "$onlyafter" "$file" ;;
      incomment) in_paragraph_comments "$file" ;;
      longsent) long_sentences "$file" ;;
      twins)    twins "$file" ;;
      *) echo "prose-lint: unknown category: $cat" >&2; exit 1 ;;
    esac
  done
done

echo "== summary (hits per category across ${#@} file(s))"
for cat in "${catlist[@]}"; do
  printf '%-10s %d\n' "$cat" "${counts[$cat]:-0}"
done
