# What reviewers and shepherds punished, and what fixed it

Drawn from the SOSP'26 tierce shepherd notes and reviews, the ASPLOS'26,
ISCA'26, and MICRO'26 reviews of epic, and the rewrite-loop audits in cxlssd
and allochar. Writing problems that reviewers name are rarely word choice; they
are density, missing definitions, narrated graphs, undefined data points, and
claims the evidence does not carry.

## Density and repetition

- Shepherd (tierce): "the paper is dense and repetitive, and reads as a sequence
  of separate claims rather than one developing argument." Fix: "State the core
  thesis once and stop re-deriving it in every section"; "Introduce one concrete
  foreground/background example early and carry it through" (tierce 1213f97).
- Reviewer B (tierce): "characterization section too dense; define ΔL2Lat, TOR,
  CHA, CLOS, PEBS periods, LDLAT at first use; design mixes implementation".
  Reviewer E: "extremely dense", "CHA used before defined". Fix: a terms table,
  every acronym expanded at first use, design reasoning separated from
  Linux/Intel engineering detail.
- Reviewer D (tierce): too many correlation figures "for a near-expected
  relationship". Fix: five figures cut to three; the space went to the
  evaluation narrative.
- Shepherd: "Cut the roadmap paragraph at the start of Section 4; it restates
  the section headings."

## Narrated graphs and recited numbers

- Reviewer C (tierce): the evaluation "narrates rather than explains graphs";
  no error bars; never discusses one of the system's own variants in the body;
  no context for cases where the system ties or loses. Shepherd: "Sections 5.4
  to 5.7 still recite scores instead of explaining them ... eight sentences and
  fifteen normalized numbers, with one explanatory clause." Fix: insight-first
  rewrite (tierce 9340bcb, 3cd1bc5), each loss attributed to noise or a named
  mechanism, error bars added, the rival's wins stated.
- ISCA (epic): "it is important for the authors to provide insights into the
  results. For example, in Figure 8(a), it is unclear why csd-seq outperforms
  host execution on knn, and underperforms on stats32." Fix: a roofline model
  paragraph explaining the trade-offs (epic ae8a36d).
- A self-contradiction survives narration and dies on explanation: the text
  said PACT "degrades" while quoting 0.68 to 0.68; the rewrite read flat-at-68%
  as a failure to use the larger budget (tierce 9340bcb).

## Undefined data points, symbols, and table entries

- ISCA (epic): "It is unclear why they evaluate CSD-Pf"; "unclear what 'sp' and
  'sp-pl' data points in Figure 11(c) represent"; "What is c-baseline in Figure
  9(b)?"; "The difference between 'N/A' and 'X' in Table 1 is unclear";
  "unclear what 'Apps' and 'One' in the last row of Table 1 refer to". Fix:
  captions define every point (epic cad97b4); Table 1 columns defined in the
  text (epic 86f433f); three names for one metric collapsed to one ("filter
  selectivity", epic aae35e2).
- MICRO (epic): "The caption refers to an 'X mark,' but no such mark is present
  in the table." A caption must match the float it describes, after every
  revision of either.
- Tierce camera-ready: "Define the third-quartile admission rule, which was used
  but never defined, and the dynprobe policy, which appeared as a table column
  with no definition" (93d4b4a).

## Numbers that cannot be located

- ISCA (epic): a headline "14x" that reviewers could not trace to a workload and
  configuration. Fix: the number was deleted (epic 5bf784b). Every headline
  number must be locatable in a figure or table by workload and configuration.
- Shepherd (tierce): "Cap numbers at two significant digits ... '4x' rather than
  '4.0x'".

## Register and vocabulary

- Shepherd (tierce) listed register slips by quote: "does dCAT actually beat",
  "harder than it looks", "the BG has to want the ways back", "is not a
  bargain", "the visually appealing sawtooth". And: "Keep the claim-first
  structure, which is the good part". Fix: each line replaced with the literal
  statement (tierce dde0fd9, f0ef62e); the structure kept.
- Shepherd: "'arms' is not a common vocabulary in our venues."
- Codex audit (tierce): "the register repeatedly slips into an economic
  metaphor"; "several sentences exceed 40 words".
- Reviewer D (tierce): "replace numbered Challenge/Finding labels with
  descriptive names".

## Claims the evidence does not carry

- Reviewer D (tierce): the paper called a documented hardware filter
  "undocumented". The fix conceded the fact in the first sentence, then bounded
  the real contribution (the encoding is not given; the one-time calibration
  recovers it). Rule: concede true points first, refute misreadings firmly, one
  hedge per claim, no defensive phrases.
- Reviewers A and D (tierce): a solo-performance gap could be a sampling-period
  confound. Fix: period-matched reruns, and the text now says "at matched
  period ... the submitted solo PACT gap was the period".
- cxlssd rewrite-loop r8 audit list: "causal verbs where the design is
  correlational"; "'shows', 'establishes', 'demonstrates' where the evidence is
  one run"; "any place a single-process comparison is phrased as a general
  property"; "any place the three-boundary claim is asserted rather than
  shown"; "caveats that were dropped when a section was compressed".
- epic todo after MICRO: "soften high-risk absolute claims such as 'first,' 'no
  existing framework,' 'beyond the reach of prior systems' ... Prefer 'to our
  knowledge,' ... 'not well supported by prior systems'"; "avoid implying full
  formal optimization if we do not".

## Framing problems prose can and cannot fix

- Co-chairs (tierce): frame the system "explicitly as an observability
  substrate, not a complete SLO enforcement system"; "Clarify virtualization
  assumptions"; state the generality implications of Intel-specific features.
  These are writing fixes: a scope paragraph, consistent terminology, a
  fallback ladder stated in prose.
- MICRO (epic) rejected the paper for "Limited novelty" after three rounds of
  polish. The authors' own conclusion: polish could not fix positioning; the
  next version reframed the contribution around residency and lifetime. Report
  this distinction explicitly when asked to polish: say which weaknesses a
  rewrite can address and which need an experiment or a reframing (cxlssd r10:
  "for each one say whether it is fixable by writing or requires an experiment
  we have not run").
- ASPLOS (epic): "Writing quality: 1. Poor. Interferes with understanding", with
  the specifics being missing mechanism ("unclear how the framework can decide
  which function should be offloaded", "unclear how the FEMU emulator works
  with ... Gem5 and ONNXim"). Fix: an end-to-end worked example (epic cf3c045,
  1f14bcf) and a platform paragraph that says what runs where (epic 0b85bcb,
  0e9be35). "Writing quality" scores usually mean missing explanation, not
  grammar.

## Rebuttal and shepherd correspondence

- Every promise in the response is a deliverable the shepherd will diff.
- Explain markup honestly (tierce shepherd response: blue marks changed claims;
  "It does not mark the extensive editorial rewriting, which would make the
  document unreadable as a diff").
- Acknowledgement wording the authors settled on after two edits: "We used
  Claude Code and ChatGPT to assist with code and writing. The work is otherwise
  the authors' own." (tierce f359ace, 5b38dbc).
