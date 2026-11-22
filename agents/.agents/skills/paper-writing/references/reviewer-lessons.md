# What reviewers and shepherds objected to, and what fixed it

Drawn from the reviews, shepherd notes, and internal rewrite audits of the lab
papers, labeled A to E. Reviewer comments are paraphrased here, not quoted.
The writing problems reviewers name are rarely about word choice. They are
density, missing definitions, narrated graphs, undefined data points, and
claims the evidence does not carry.

## Density and repetition

- A shepherd found paper E dense and repetitive, reading as a series of
  separate claims instead of one developing argument. The fix stated the core
  thesis once instead of re-deriving it in every section, and introduced one
  concrete foreground/background example early and carried it through.
- Reviewers found the characterization section of paper E too dense. Terms and
  acronyms appeared before their definitions, and the design section mixed in
  implementation detail. The fix added a terms table, expanded every acronym
  at first use, and separated design reasoning from Linux and Intel
  engineering detail.
- A reviewer thought paper E spent too many correlation figures on an expected
  relationship. Five figures became three, and the space went to the
  evaluation narrative.
- The shepherd asked for a roadmap paragraph to be cut because it restated the
  section headings.

## Narrated graphs and recited numbers

- A reviewer found that paper E's evaluation narrated graphs instead of
  explaining them. It had no error bars, never discussed one of the system's
  own variants, and gave no context where the system tied or lost. The
  shepherd later counted one subsection at eight sentences, about fifteen
  normalized numbers, and one explanatory clause. The fix was an insight-first
  rewrite. Each loss is attributed to noise or a named mechanism, error bars
  were added, and the rival's wins are stated.
- A reviewer asked paper D to explain its results, for example why one
  configuration beat host execution on one workload and lost on another. The
  fix was a roofline-model paragraph that explains the trade-off.
- Explaining a result exposes contradictions that narration hides. The text of
  paper E said a baseline "degrades" while quoting the same value at both
  ends. The rewrite read the flat line as a failure to use the larger budget.

## Undefined data points, symbols, and table entries

- Reviewers of paper D could not tell why one configuration was evaluated,
  what two plotted variants meant, what one baseline label referred to, how
  two table symbols differed, or what two labels in a table's last row
  referred to. The fix defined every point in the captions, defined the table
  columns in the text, and collapsed three names for one metric into one.
- A later reviewer of paper D found a caption that described a mark the table
  did not contain. A caption must match its float after every revision of
  either.
- Paper E's camera-ready plan defined an admission rule that had been used but
  never defined, and a policy that had appeared only as a table column.

## Numbers that cannot be located

- Reviewers could not trace a headline speedup in paper D to a workload and a
  configuration, and the number was deleted. Every headline number must be
  locatable in a figure or table by workload and configuration.
- The shepherd of paper E asked for numbers capped at two significant digits,
  "4x" instead of "4.0x".

## Register and vocabulary

- The shepherd of paper E listed informal phrases by example. They included
  asking whether one system "actually beats" another, calling a problem
  harder than it looks, saying a component "has to want" a resource back,
  calling a trade-off not a bargain, and praising a plot's shape as visually
  appealing. The shepherd also said to keep the claim-first structure. Each
  phrase was replaced with the literal statement, and the structure stayed.
- The same shepherd noted that "arms" is not common vocabulary in systems
  venues.
- An automated audit of paper E found the register slipping into economic
  metaphor and several sentences over 40 words.
- A reviewer asked paper E to replace numbered Challenge and Finding labels
  with descriptive names.

## Claims the evidence does not carry

- A reviewer pointed out that paper E called a documented hardware filter
  undocumented. The fix conceded the fact in the first sentence and then
  bounded the real contribution, which was recovering an encoding the
  documentation does not give. Concede true points first, refute misreadings
  firmly, use one hedge per claim, and avoid defensive phrases.
- Reviewers suspected that a solo-performance gap in paper E came from a
  sampling-period confound. The fix was period-matched reruns, and the text
  now states that at matched period the gap was the sampling period.
- Paper B's internal rewrite audit listed claims to search for. These were
  causal verbs where the design is correlational, "shows" or "establishes"
  where the evidence is one run, a single-process comparison phrased as a
  general property, an asserted claim that should be shown, and caveats
  dropped when a section was compressed.
- After a rejection, paper D's todo list said to soften absolute claims such
  as "first" and "no existing framework", to prefer "to our knowledge" and
  "not well supported by prior systems", and to avoid implying a full formal
  optimization the system does not perform.

## Framing problems prose can and cannot fix

- Program chairs asked paper E to frame the system as an observability
  substrate instead of a complete enforcement system, to state its
  virtualization assumptions, and to say what its reliance on vendor-specific
  features means for generality. These are writing fixes. A scope paragraph,
  consistent terminology, and a fallback path stated in prose addressed them.
- Paper D was rejected for limited novelty after three rounds of polish. The
  authors concluded that polish could not fix positioning, and the next
  version reframed the contribution. When asked to polish, say which
  weaknesses a rewrite can address and which need an experiment or a
  reframing.
- A reviewer rated paper D's writing quality as poor enough to interfere with
  understanding. The specifics were missing mechanism, such as how the system
  decides what to offload and how the simulators connect. The fix was an
  end-to-end worked example and a platform paragraph that says what runs
  where. A low writing score usually means missing explanation, not grammar.

## Rebuttal and shepherd correspondence

- Every promise in the response is a deliverable the shepherd will check.
- Explain markup honestly. Paper E's response said that blue marks changed
  claims and does not mark the extensive editorial rewriting, which would make
  the document unreadable as a diff.
- The acknowledgement wording the authors settled on after two edits is "We
  used Claude Code and ChatGPT to assist with code and writing. The work is
  otherwise the authors' own."
