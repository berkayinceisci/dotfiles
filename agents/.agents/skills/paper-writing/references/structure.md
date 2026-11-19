# Structure: paragraphs, sections, floats, numbers, claims

Rules below come from the five repositories' commit messages, in-repo writing
plans (cxlssd AGENTS.md and section blueprint, tierce camera-ready plans and
shepherd notes, allochar rewrite plan and review prompts, epic todo and lint),
and the diffs themselves.

## Paragraphs

- **One claim per paragraph** (tierce cr2-tracker). The paragraph's purpose
  sentence comes first, then mechanism, then numbers as support, then an
  explicit consequence if there is one.
- **Insight-first** (tierce 9340bcb, 3cd1bc5). The run-in heading or first
  sentence states what the result reveals, not the condition under which it was
  measured. `\para{1:1 ratio.}` became `\para{Placement quality, not sampling
  rate, separates the systems.}`; another became `\para{When promoting more
  hurts.}`. First sentence: "The one solo loss is diagnostic." Numbers follow in
  parentheses: "(80% vs. 83%)". Every loss gets a mechanism: "because hint faults
  and hotness counters promote frequently touched pages whether or not their
  misses stall the CPU". Where the rival leads is stated plainly ("PACT leads
  wMLP on bc_kron (75% vs 74%)", which the old text omitted).
- **Purpose first, declarative numbers, earned consequences** (dst 8b37c39, "the
  v1 register"). The paragraph opens with what it establishes ("Merging's
  contribution is already in every measurement."), names the mechanism with a
  cross-reference to where it was introduced, states numbers flat ("accounts for
  70% of local bandwidth at 4 KB"), and announces consequences only when they
  follow in the same paragraph ("Two consequences follow. The deficits reported
  elsewhere ... And merging is a concurrency-era lever ...").
- **The allochar section template** (752465e, d35253d): each mechanism section
  opens by naming the assumption, the property that breaks it, the state left
  behind, and who pays, in prose; the experimental configurations lead, the
  controls follow; each ends with a transfer rule and the excluded neighbours.
  Later (f14a958) the template nouns themselves ("the state left behind is",
  "the payer is") were turned back into verbs: "The allocator call path then
  pays for the cache contents through ...".
- **No topic sentence that restates the paragraph following it.** Fourteen were
  rejected in one round (allochar f14a958): "GAPBS shows the favorable case",
  "The direct intervention changes only the interval", "cppcheck provides the
  allocator-side intervention". If the first sentence is a label for the
  paragraph, delete it and let the paragraph start on its first fact.
- **No paragraph-final restatement.** "cut two paragraph-final restatements"
  (allochar 5b1a4e4); "shorten the caption, which restated the sentence above
  it" (tierce 5d4c0d5); "cut the conclusion's redundant final sentence" (dst).
- **Transitions must carry a relationship.** "Adding 'therefore,' 'furthermore,'
  or 'we next' cannot repair a missing premise. Prefer reordering, combining, or
  removing disconnected material to adding repetitive bridge text." (cxlssd
  blueprint). Roadmaps are cut when they restate nearby headings (the §4
  roadmap in tierce) and kept when they orient across a long distance (the
  tierce intro roadmap was completed, not cut).
- **Explain rather than narrate.** The SOSP shepherd: "Sections 5.4 to 5.7
  still recite scores instead of explaining them ... eight sentences and fifteen
  normalized numbers, with one explanatory clause." The fix restructured a
  15-number recital into three claims, each with its mechanism.
- **Sentences: one clause each.** "overloaded multi-clause sentences split into
  clean ones, verbs restored" (allochar f14a958). A Codex audit of tierce found
  sentences over 40 words and prescribed "Split setup, mechanism, and
  consequence into separate sentences." Semicolon or period replaces ", where /
  , and / but the" chains. Beware the opposite failure: tierce 5b38dbc partially
  reverted participle folds ("never releasing below", "validating", ", each
  paired") where they had made sentences long again.

## Headings, run-in leads, caption titles

- Section titles and subsection titles are **descriptive noun phrases** naming
  what is done or shown. "Request Timing: Benefit Above, Cost Below" became
  "Changing When a Request Is Issued"; "Charge the Execution That Pays"
  (imperative) became "Accounting for the Whole Execution" (cxlssd 6ad4b77).
  "Three Ways a Write Path Fails" became "Occupancy, Delivery, and Dependency
  Limits" (dst). "The Access Path" became "From a CPU Load to an SSD Access"
  (cxlssd). Parallel sections read in parallel: changing when a request is
  issued, changing what crosses the boundary, avoiding the device for selected
  accesses.
- Run-in bold leads are **topical nouns**, not verdicts: "Yet ordinary Linux
  workloads lose anyway." became "Software limits on remote writes."; "Blind
  spots define the method." became "Scope."; "Real workloads remain the harder
  test." became "Workload validation." (dst). Sentence case.
- Titles and heads reuse the paper's own vocabulary: "the paper never names an
  assumption; its own vocabulary is limits, boundaries, and paths" (dst
  4bdf339 note on a title proposal).
- Caption titles are one-line noun phrases that name what the float shows,
  measured against the real column budget: "The Same Device Costs Different
  Programs Very Differently" became "Per-program cost of one device"; "Size does
  not predict the penalty" became "Footprint against penalty"; "Disabling late
  lookahead keeps the early gain" became "Effect of gating late lookahead"
  (cxlssd dda7ade, all 32 captions). "One write, three paths" became "QD1 write
  latency by access path"; "What merging was quietly contributing." became
  "Effect of request merging on write bandwidth." (dst 487ff47).

## Captions

- Two or three rendered lines (cxlssd AGENTS.md; dst 95a1861 "cut every caption
  to two or three lines; detail moves to the sections"; dst 64e61f7 "hold every
  caption to three lines").
- A caption says **what is plotted, units, and what the glyphs mean**: "The
  caption still carries what the glyphs mean, which is the part a reader cannot
  get from the body." (tierce e01c978). Legend keys as colon pairs:
  "L1Lat/L2Lat/L3Lat: miss latencies; L3MLP: LLC-miss MLP".
- Results and r values move out of captions into the body or comments: "Each
  point is one colocation experiment. r = +0.91 (local) and r = +0.96 (remote)."
  became "Each point represents one colocation experiment, grouped by memory
  placement." (tierce ce7fa23). Shepherd: "Trim captions so each says what the
  figure shows rather than stating results."
- Replication counts: one blanket sentence in Method ("repeated at least three
  times") replaces per-caption "Medians of three runs" (tierce 2a21b2c). State
  whether a number is a mean or a median where it matters.
- Schematics are labeled as such: "Schematic. The shape of an occupancy-limited
  path." (dst).
- Every data point in a figure is defined somewhere the reader can find it
  (ISCA reviewer: "unclear what 'sp' and 'sp-pl' data points represent"; "What
  is c-baseline in Figure 9(b)?"). A caption must match the table ("The caption
  refers to an 'X mark,' but no such mark is present").
- Subplot references: `Figure~\ref{fig:x}a`, rendered "Figure 5a", never
  "Figure 5[a]" (cxlssd SKILL.md).
- When a figure is enlarged or clarified, drop the prose that now only restates
  it (dst 4b742f0 "drop prose the enlarged Figure 9 now states").

## Numbers

- **Keep every number; add none.** A polish round that dropped 28 numbers
  instead of moving them to prose was reverted (allochar ed5109c, e4efb7a
  "table triggers-only, all numbers in prose"). The allochar drafting prompt:
  "Keep every number that the brief does not tell you to remove; add none." The
  review prompt lists "every number in the revision that is absent from the
  brief or the original section, quoted".
- **Say what each number measures**: "je holds 98% on 644" became "je's
  coverage at peak anonymous memory on 644 is 98%" (allochar 9163f47); "the
  graph read is served 94.6% from the backend" became "the graph read's NAND-read
  bytes are 94.6% of its CXL-read bytes" (cxlssd). Name numerator, denominator,
  and baseline (cxlssd blueprint).
- **One meter per comparison.** dst 550fa2a put all checkpoint numbers on
  device bandwidth after a sentence compared "application-meter OLTP against
  device-meter checkpoint numbers" and was cut. Percent-of-all-DRAM was unified
  across tierce 5.4 and 5.6.
- **Plain digits.** No `$\sim$` before an exact figure ("matches local at 2.9
  GB/s", dst 94f2df9). Ranges as "4.3--340 ms" not "anywhere from 4.3 ms to
  340 ms" (tierce). "holds fourteen times less at the device" became "holds
  one-fourteenth as much" (dst).
- **Two significant digits**: "4x" rather than "4.0x" (tierce shepherd).
- **Human-scale over false precision**: "0.0000152" became "essentially zero";
  "0.012% of allocations" became "about one allocation in 8,000" (allochar
  5b1a4e4).
- **Counts replace vague quantifiers**: "Most application configurations have
  several competitive allocator choices" became "372 of 382 application points
  have at least two allocators within 5%" (allochar a04ffca). "half again as
  much" became "47.5--49.8% more" (cxlssd). "(tens of microseconds per
  invocation)" became "(microseconds per invocation)" because that is what the
  data said (epic 247df86).
- **Numbers are support, not subject.** "Gather lookahead removes 92.1% of
  PageRank's demand misses and leaves 95.9% of its link traffic." has a concrete
  subject and the numbers attached; "An intervention can remove 92.1% ..." had
  an abstract subject and a modal (cxlssd).
- **State the direction that was measured**: "merging costs bandwidth (-9%
  RDMA, -24% TCP)" became "disabling it raises bandwidth by 10% on RDMA and 31%
  on TCP" (dst 8b37c39).
- **Headline results are speedups against a named baseline**: "improve PageRank
  and SSSP performance by 1.50x and up to 1.15x" against "unmodified kernels";
  convert a runtime reduction r with speedup = 1/(1-r) and never report it as a
  throughput increase (cxlssd blueprint). "speedups of 4.2x over host baselines
  and 1.6x over the strongest prior system, on average." replaced a
  three-statistic sentence (epic cd72df2).
- **Each numerical result has one primary home**; the conclusion synthesizes,
  it does not repeat (cxlssd review.md).

## Claims and evidence

- Causal verbs only where the design is a controlled intervention; "shows",
  "establishes", "demonstrates" only where the evidence is more than one run;
  a single-process comparison is never phrased as a general property (cxlssd
  rewrite-loop r8).
- Epistemic verbs by evidence grade, upgraded when evidence lands: "tracing its
  assignments shows that this workload's data files are labeled warm" was first
  narrowed to "The observed behavior is consistent with ... We infer that
  placement from the device-side occupancy", then, after an eBPF trace was
  collected, became "An eBPF trace of F2FS's write-hint assignments confirms it"
  (dst c136a2e, cae7b64). Hedging is calibration, not minimization.
- "the measured 271 us consists of three fabric writes" became "is consistent
  with three fabric writes ... the raw trace behind this decomposition was not
  retained, so we treat it as an illustration" (dst c136a2e). Say what was not
  run as a fact, not as an apology.
- Caveat lives in the same sentence or the next one as the claim it qualifies
  (cxlssd r3). A caveat that appears three times in an introduction is reduced
  to one statement at the experiment and one in the limits (cxlssd 357af8c).
- Search before submission for: undocumented, all, always, guarantee, exact,
  perfect, state-of-the-art (tierce audit plan). Prefer "protected" and
  "best-effort" over absolutes.
- Related work: argue from the paper's own counterexamples ("Each
  single-boundary account is individually correct and jointly misleading, which
  is the argument for measuring them together", cxlssd bc6b6ae), not from "we
  do not claim the first characterization". Do not enter novelty contests the
  paper does not need to win; a contribution list that advertises what the
  related-work section concedes "argued against itself" (cxlssd c057bb2).
  Concede a true overlap first and bound it: "same signal, different setting"
  (tierce vs. Colloid).
- Do not promote a heuristic to a validated predictor, a hand-selected setting
  to an automatic policy, an analysis prototype to an evaluated compiler, or a
  fixed-sweep timing to equal-accuracy completion (cxlssd SKILL.md). Do not
  imply full formal optimization if the system does not do it (epic todo).
- Distinguish programs, workload configurations, paired runs, and repetitions;
  never inflate a workload count (cxlssd blueprint).

## Abstract

Progression (cxlssd blueprint, confirmed by dst and epic rewrites): problem and
gap in one or two sentences; characterization and the insight it yields;
"Guided by these findings, we design ..."; why each additional mechanism is
needed (not a list); one results sentence against a named baseline. Under 200
words (cxlssd b5a3241 cut 302 to 174; dst 312e1d3 cut to 15 lines; allochar
d4f6b50 "about 200 words"). No reversal counts or mechanism inventories. No
generic significance line after the results. Do not open on a review argument
("falsify three proxy inferences") or a broad technology preamble.

## Introduction

- Open on the concrete number or paradox, not the truism: "Returning freed pages
  ... is normally understood as a trade: give back memory, pay a little time."
  became an opening on the datacenter tax with the ISCA'15 fleet number
  (allochar 20ffc62). The policy paragraph ends on the research question.
- Order that survived review: landscape and opportunity; downside and research
  question; the challenges; prior work and the exact gap (conceded, not
  dismissed); insight and method; findings and what they imply; designs and
  evaluation highlights; contributions (cxlssd blueprint). Epic's todo: "Reframe
  it as problem -> challenge -> insight -> mechanism -> evidence" because it
  "reads partly like a feature list".
- A taxonomy must not carry the argument: an intro that "spent a dense paragraph
  drawing definitional boundaries ... before reaching a single result" was "the
  shape of a taxonomy carrying the argument rather than the argument carrying
  the taxonomy" (allochar e5e552f). Introduce a technique with one clause saying
  what it does before using its name in results.
- Cut: the rhetorical research question, the softened contribution bullets, and
  framings like "seven policies survive this procedure" (allochar 20ffc62).
- Move the motivation figure into the intro if a reviewer says the design's
  necessity "would be better established earlier" (epic 3f17460).

## Contributions

- "We make three contributions:" attached to the end of the preceding paragraph,
  not a paragraph on its own (cxlssd blueprint). Adjust the count to the truth;
  exactly three is the common case (cxlssd r3 "exactly three items").
- Each bullet opens with "We" plus a precise verb ("systematically
  characterize", "design", "develop"), carries its numbers inline, has no bold
  label phrase, no section reference, no slogan. "A phenomenon. Disaggregation
  exposes ..." became "We show that disaggregation exposes" (dst 6a3d82b). "A
  systematic characterization of CXL-SSD performance" became "We systematically
  characterize CXL-SSD performance" (cxlssd).
- Each contribution names a claim and the evidence class that supports it; a
  single bullet "cataloguing eight findings" is "the second abstract problem"
  (cxlssd r3).
- No defensive paragraph after the list.

## Design and implementation sections

- Problem, observation, design choice, implementation, evaluation, in that
  order. Define data structures and symbols before using them. Show what happens
  to an actual access or graph before generalizing (cxlssd AGENTS.md).
- Separate design reasoning from Linux/Intel engineering detail (tierce,
  reviewers B and C). Formal design-section terms (CallState, SharedState) do
  not appear in abstract, intro, background, or conclusion (epic lint, severity
  error).
- Explain why, not only what: the MICRO reviewer flagged a description that
  "does not clearly explain *why*". One end-to-end worked example on one
  foreground/background pair or one program carries the design (tierce 1213f97,
  epic cf3c045).
- An implementation paragraph lists components as a parallel noun list:
  "a epic.accel("xpu", params) call in the DSL, a code emitter in the compiler,
  and a dispatcher in the runtime." (epic fab46e7).

## Evaluation

- Pose the questions in prose, not an itemize: "Our evaluation asks four
  questions: whether ..." (epic ae0b7eb).
- Platform paragraph says what runs where, not why that fidelity was needed:
  "The complete host, NVMe, FTL, flash, and firmware path runs in FEMU" replaced
  a paragraph beginning "Evaluating a full-stack ISC system requires both
  end-to-end system fidelity and component-level cycle accuracy." (epic
  0b85bcb).
- Every case where the system ties or loses gets a stated reason, noise or
  mechanism, with error bars (tierce reviewer C). Baseline omissions are
  justified architecturally ("SoarAlto omitted, same global-MLP family as
  PACT").
- Define every policy or configuration that appears in a table column (tierce
  93d4b4a: "the dynprobe policy, which appeared as a table column with no
  definition"). Define Table 1 symbols in the text ("The difference between
  'N/A' and 'X' in Table 1 is unclear", ISCA).
- Unify the normalization convention across subsections.
- A result sentence has one statistic phrasing; name the statistic once in
  Method and say "on average" thereafter (epic cd72df2).

## Limitations and conclusion

- Each limitation is one sentence ending in what is planned: a 12-line
  write-intensive discussion became "Write-intensive workloads would benefit
  from write buffering and coalescing, both planned extensions." (epic e4b977c).
  A 62-line bulleted limitations section became one paragraph (epic 7c30ecd).
- The conclusion argues rather than recaps (allochar 5b1a4e4: "costs land
  outside allocator code, the method replaces guessing, and the properties that
  decide a policy's sign are ones the application knows and has no way to
  express"). Make the point once (cxlssd conclusion 293 to 133 words). End on
  the open problem, not a summary.
- Finding boxes, if used, hold the rule alone ("averaging 41 words against 75",
  allochar ee015a5) or are folded into prose entirely (tierce).

## Page-budget cuts

- Delete redundant subsections and floats before shrinking figures or fonts;
  "the extra page was granted for figure legibility" (tierce 93d4b4a). Do not
  "compress explanations or shrink fonts, margins, or template spacing" (cxlssd
  AGENTS.md).
- Merge tables with identical columns; drop a float whose numbers the prose
  already carries; fold a one-result subsection into the section its result
  supports.
- Archive deleted detail as a LaTeX comment with the commit that held it
  ("% Original caption detail", "git show f752231:v1/char.tex").

## Rebuttals and shepherd responses

- Concede true points in the first sentence; refute misreadings firmly and
  politely; one hedge per claim; no defensive phrases such as "we do not hide"
  (tierce rebuttal strategy).
- Every "we will add X" is a hard deliverable the shepherd will diff against.
- Tag revised sentences to the reviewer question they answer
  (`\reviewer{Q}{B7,C2}`, epic 793b27a) and strip the markup before
  submission.
- Explain a marked-up PDF honestly: "Blue marks new sections and individual
  sentences whose claims changed. It does not mark the extensive editorial
  rewriting, which would make the document unreadable as a diff." (tierce
  shepherd response).

## Working method the authors converged on

- Proposals live in the LaTeX as colored text with their justification (dst:
  blue = edit, orange = proposal, red = removal flag); accepted ones become
  plain text; all color is stripped before submission (dst 5261321).
- A whole-paper read after every round: "every paragraph was reviewed after it
  was written" (tierce shepherd message).
- A model-produced rewrite is adopted paragraph by paragraph, never wholesale:
  "27 of 52 body paragraphs take the new version, the rest stay. An earlier
  wholesale splice silently dropped six control paragraphs and was reverted."
  (allochar f14a958).
- Track the de-AI lint to zero P0 and zero P1 before calling a round done
  (allochar 44ca4fb).
