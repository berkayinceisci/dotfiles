# Structure: paragraphs, sections, floats, numbers, claims

Rules below come from the lab papers' commit messages, their in-repo writing
plans, review prompts, todo files and lint configurations, reviewer feedback
(paraphrased, not quoted), and the diffs themselves. Papers are labeled A to E
and a proposal F.

## Paragraphs

- **One claim per paragraph** (paper E cr2-tracker). The paragraph's purpose
  sentence comes first, then mechanism, then numbers as support, then an
  explicit consequence if there is one.
- **Insight-first** (paper E). The run-in heading or first
  sentence states what the result reveals, not the condition under which it was
  measured. `\para{1:1 ratio.}` became `\para{Placement quality, not sampling
  rate, separates the systems.}`; another became `\para{When promoting more
  hurts.}`. First sentence: "The one solo loss is diagnostic." Numbers follow in
  parentheses: "(80% vs. 83%)". Every loss gets a mechanism: "because hint faults
  and hotness counters promote frequently touched pages whether or not their
  misses stall the CPU". When no mechanism has been measured, say the cause
  is unresolved, or name the candidate and what would test it. An invented
  explanation is worse than an open one. Where the rival leads is stated plainly ("PACT leads
  wMLP on bc_kron (75% vs 74%)", which the old text omitted).
- **Purpose first, declarative numbers, earned consequences** (paper C, "the
  v1 register"). The paragraph opens with what it establishes ("Merging's
  contribution is already in every measurement."), names the mechanism with a
  cross-reference to where it was introduced, states numbers flat ("accounts for
  70% of local bandwidth at 4 KB"), and announces consequences only when they
  follow in the same paragraph ("Two consequences follow. The deficits reported
  elsewhere ... And merging is a concurrency-era lever ...").
- **The paper A section template** : each mechanism section
  opens by naming the assumption, the property that breaks it, the state left
  behind, and who pays, in prose; the experimental configurations lead, the
  controls follow; each ends with a transfer rule and the excluded neighbours.
  Later  the template nouns themselves ("the state left behind is",
  "the payer is") were turned back into verbs: "The allocator call path then
  pays for the cache contents through ...".
- **No topic sentence that restates the paragraph following it.** Fourteen were
  rejected in one round (paper A): "GAPBS shows the favorable case",
  "The direct intervention changes only the interval", "cppcheck provides the
  allocator-side intervention". If the first sentence is a label for the
  paragraph, delete it and let the paragraph start on its first fact.
- **No paragraph-final restatement.** "cut two paragraph-final restatements"
  (paper A); "shorten the caption, which restated the sentence above
  it" (paper E); "cut the conclusion's redundant final sentence" (paper C).
- **Transitions must carry a relationship.** "Adding 'therefore,' 'furthermore,'
  or 'we next' cannot repair a missing premise. Prefer reordering, combining, or
  removing disconnected material to adding repetitive bridge text." (paper B
  blueprint). Roadmaps are cut when they restate nearby headings (the §4
  roadmap in paper E) and kept when they orient across a long distance (the
  paper E intro roadmap was completed, not cut).
- **Explain rather than narrate.** A shepherd objected that several
  evaluation subsections recited scores instead of explaining them, with about
  fifteen normalized numbers and a single explanatory clause. The fix
  restructured the recital into three claims, each with its mechanism.
- **Sentences: one claim each.** "overloaded multi-clause sentences split into
  clean ones, verbs restored" (paper A). A Codex audit of paper E found
  sentences over 40 words and prescribed "Split setup, mechanism, and
  consequence into separate sentences." A period replaces ", where / , and /
  but the" chains. The original audit also allowed a semicolon, which rule 11
  now rations. Beware the opposite failure: paper E  partially
  reverted participle folds ("never releasing below", "validating", ", each
  paired") where they had made sentences long again. Length alone is a
  prompt to reread. A 45-word sentence that states one cause and its effect
  can stay. Splitting every sentence to the same short length makes the text
  monotonous.

## Headings, run-in leads, caption titles

- Section titles and subsection titles are **descriptive noun phrases** naming
  what is done or shown. "Request Timing: Benefit Above, Cost Below" became
  "Changing When a Request Is Issued"; "Charge the Execution That Pays"
  (imperative) became "Accounting for the Whole Execution" (paper B).
  "Three Ways a Write Path Fails" became "Occupancy, Delivery, and Dependency
  Limits" (paper C). "The Access Path" became "From a CPU Load to an SSD Access"
  (paper B). Parallel sections read in parallel: changing when a request is
  issued, changing what crosses the boundary, avoiding the device for selected
  accesses.
- Run-in bold leads are **topical nouns**, not verdicts: "Yet ordinary Linux
  workloads lose anyway." became "Software limits on remote writes."; "Blind
  spots define the method." became "Scope."; "Real workloads remain the harder
  test." became "Workload validation." (paper C). Sentence case.
- Titles and heads reuse the paper's own vocabulary: "the paper never names an
  assumption; its own vocabulary is limits, boundaries, and paths" (paper C
   note on a title proposal).
- Caption titles are one-line noun phrases that name what the float shows,
  measured against the real column budget: "The Same Device Costs Different
  Programs Very Differently" became "Per-program cost of one device"; "Size does
  not predict the penalty" became "Footprint against penalty"; "Disabling late
  lookahead keeps the early gain" became "Effect of gating late lookahead"
  (paper B, all 32 captions). "One write, three paths" became "QD1 write
  latency by access path"; "What merging was quietly contributing." became
  "Effect of request merging on write bandwidth." (paper C).

## Captions

- Two or three rendered lines (paper B; paper C  "cut every caption
  to two or three lines; detail moves to the sections"; paper C  "hold every
  caption to three lines").
- A caption says **what is plotted, units, and what the glyphs mean**: "The
  caption still carries what the glyphs mean, which is the part a reader cannot
  get from the body." (paper E). Legend keys as colon pairs:
  "L1Lat/L2Lat/L3Lat: miss latencies; L3MLP: LLC-miss MLP".
- Results and r values move out of captions into the body or comments: "Each
  point is one colocation experiment. r = +0.91 (local) and r = +0.96 (remote)."
  became "Each point represents one colocation experiment, grouped by memory
  placement." (paper E). The shepherd asked for captions that say what the
  figure shows and leave the results to the text.
- Replication counts: one blanket sentence in Method ("repeated at least three
  times") replaces per-caption "Medians of three runs" (paper E). State
  whether a number is a mean or a median where it matters.
- Schematics are labeled as such: "Schematic. The shape of an occupancy-limited
  path." (paper C).
- Every data point in a figure is defined somewhere the reader can find it.
  Reviewers of paper D could not tell what two plotted variants and one
  baseline label meant. A caption must match its table. One caption described
  a mark the table did not contain.
- Subplot references: `Figure~\ref{fig:x}a`, rendered "Figure 5a", never
  "Figure 5[a]" (paper B).
- When a figure is enlarged or clarified, drop the prose that now only restates
  it (paper C  "drop prose the enlarged Figure 9 now states").

## Numbers

- **Keep every number; add none.** A polish round that dropped 28 numbers
  instead of moving them to prose was reverted (paper A,
  "table triggers-only, all numbers in prose"). The paper A drafting prompt:
  "Keep every number that the brief does not tell you to remove; add none." The
  review prompt lists "every number in the revision that is absent from the
  brief or the original section, quoted".
- **Say what each number measures**: "je holds 98% on 644" became "je's
  coverage at peak anonymous memory on 644 is 98%" (paper A); "the
  graph read is served 94.6% from the backend" became "the graph read's NAND-read
  bytes are 94.6% of its CXL-read bytes" (paper B). Name numerator, denominator,
  and baseline (paper B blueprint).
- **One meter per comparison.** paper C  put all checkpoint numbers on
  device bandwidth after a sentence compared "application-meter OLTP against
  device-meter checkpoint numbers" and was cut. Percent-of-all-DRAM was unified
  across paper E 5.4 and 5.6.
- **Plain digits.** No `$\sim$` before an exact figure ("matches local at 2.9
  GB/s", paper C). Ranges as "4.3--340 ms" not "anywhere from 4.3 ms to
  340 ms" (paper E). "holds fourteen times less at the device" became "holds
  one-fourteenth as much" (paper C).
- **At most two significant digits for ratios and speedups.** "4x" rather than
  "4.0x" (paper E shepherd). Measured values keep the precision the evidence
  supports, and exact counts and identifiers are never rounded.
- **Human-scale over false precision**: "0.0000152" became "essentially zero";
  "0.012% of allocations" became "about one allocation in 8,000" (paper A
). Round or replace a value only with the authors' approval.
  Otherwise propose the change in the report and leave the number in place.
- **Counts replace vague quantifiers**: "Most application configurations have
  several competitive allocator choices" became "372 of 382 application points
  have at least two allocators within 5%" (paper A). "half again as
  much" became "47.5--49.8% more" (paper B). "(tens of microseconds per
  invocation)" became "(microseconds per invocation)" because that is what the
  data said (paper D).
- **Numbers are support, not subject.** "Gather lookahead removes 92.1% of
  PageRank's demand misses and leaves 95.9% of its link traffic." has a concrete
  subject and the numbers attached; "An intervention can remove 92.1% ..." had
  an abstract subject and a modal (paper B).
- **State the direction that was measured**: "merging costs bandwidth (-9%
  RDMA, -24% TCP)" became "disabling it raises bandwidth by 10% on RDMA and 31%
  on TCP" (paper C).
- **Headline results are speedups against a named baseline**: "improve PageRank
  and SSSP performance by 1.50x and up to 1.15x" against "unmodified kernels";
  convert a runtime reduction r with speedup = 1/(1-r) and never report it as a
  throughput increase (paper B blueprint). "speedups of 4.2x over host baselines
  and 1.6x over the strongest prior system, on average." replaced a
  three-statistic sentence (paper D).
- **Each numerical result has one primary home**; the conclusion synthesizes,
  it does not repeat (paper B).

## Claims and evidence

- Causal verbs only where the design is a controlled intervention. "shows",
  "establishes", and "demonstrates" need evidence that covers the claim's
  scope. The controls, the uncertainty, and the alternatives left open matter
  more than the run count. The paper B review notes audit flagged these
  verbs "where the evidence is one run", and more runs of an uncontrolled
  comparison do not fix that. A single-process comparison is never phrased as
  a general property (paper B review notes).
- Epistemic verbs by evidence grade, upgraded when evidence lands: "tracing its
  assignments shows that this workload's data files are labeled warm" was first
  narrowed to "The observed behavior is consistent with ... We infer that
  placement from the device-side occupancy", then, after an eBPF trace was
  collected, became "An eBPF trace of F2FS's write-hint assignments confirms it"
  (paper C). Hedging is calibration, not minimization.
- "the measured 271 us consists of three fabric writes" became "is consistent
  with three fabric writes ... the raw trace behind this decomposition was not
  retained, so we treat it as an illustration" (paper C). Say what was not
  run as a fact, not as an apology.
- Caveat lives in the same sentence or the next one as the claim it qualifies
  (paper B review notes). A caveat that appears three times in an introduction is reduced
  to one statement at the experiment and one in the limits (paper B).
- Search before submission for: undocumented, all, always, guarantee, exact,
  perfect, state-of-the-art (paper E audit plan). Prefer "protected" and
  "best-effort" over absolutes.
- Related work: argue from the paper's own counterexamples ("Each
  single-boundary account is individually correct and jointly misleading, which
  is the argument for measuring them together", paper B), not from "we
  do not claim the first characterization". Do not enter novelty contests the
  paper does not need to win; a contribution list that advertises what the
  related-work section concedes "argued against itself" (paper B).
  Concede a true overlap first and bound it: "same signal, different setting"
  (paper E vs. Colloid).
- Do not promote a heuristic to a validated predictor, a hand-selected setting
  to an automatic policy, an analysis prototype to an evaluated compiler, or a
  fixed-sweep timing to equal-accuracy completion (paper B). Do not
  imply full formal optimization if the system does not do it (paper D todo).
- Distinguish programs, workload configurations, paired runs, and repetitions;
  never inflate a workload count (paper B blueprint).

## Abstract

Progression (paper B blueprint, confirmed by paper C and paper D rewrites): problem and
gap in one or two sentences; characterization and the insight it yields;
"Guided by these findings, we design ..."; why each additional mechanism is
needed (not a list); one results sentence against a named baseline. Under 200
words (paper B  cut 302 to 174; paper C  cut to 15 lines; paper A
 "about 200 words"). No reversal counts or mechanism inventories. No
generic significance line after the results. Do not open on a review argument
("falsify three proxy inferences") or a broad technology preamble.

## Introduction

- Open on the concrete number or paradox, not the truism: "Returning freed pages
  ... is normally understood as a trade: give back memory, pay a little time."
  became an opening on the datacenter tax with the ISCA'15 fleet number
  (paper A). The policy paragraph ends on the research question.
- Order that survived review: landscape and opportunity; downside and research
  question; the challenges; prior work and the exact gap (conceded, not
  dismissed); insight and method; findings and what they imply; designs and
  evaluation highlights; contributions (paper B blueprint). Paper D's todo: "Reframe
  it as problem -> challenge -> insight -> mechanism -> evidence" because it
  "reads partly like a feature list".
- A taxonomy must not carry the argument: an intro that "spent a dense paragraph
  drawing definitional boundaries ... before reaching a single result" was "the
  shape of a taxonomy carrying the argument rather than the argument carrying
  the taxonomy" (paper A). Introduce a technique with one clause saying
  what it does before using its name in results.
- Cut: the rhetorical research question, the softened contribution bullets, and
  framings like "seven policies survive this procedure" (paper A).
- Move the motivation figure into the intro if a reviewer says the design's
  necessity should be established earlier (paper D).

## Background and motivation (outside the repos)

These sections were not mined from the repos. They are organizing defaults,
and the venue and paper type take precedence.

- Background supplies only the prerequisites the design and evaluation use.
  Each term or mechanism it introduces is used later, and one that is not
  gets cut. Define it once here and reuse the same name (the terms-table
  rule).
- Motivation establishes the unresolved problem with the paper's own
  evidence. One measurement or example shows the gap and carries forward as
  the running example (paper E). The section ends with the property
  the design must have. A preview of the design belongs in the design
  section.
- Keep the two apart when both exist. Background that argues, or motivation
  that teaches, makes the reader wait for the point.

## Related work (outside the repos, except where cited)

- Organize by the dimensions that matter to the contribution, such as what is
  measured, at which layer, and under which assumption. Each group ends with
  the specific difference from this paper.
- Argue from the paper's own counterexamples and concede true overlap first,
  then bound it. "Claims and evidence" above has the paper B and paper E
  examples. Do not enter novelty contests the paper does not need to win.
- Describe what prior work does in its own terms before saying what it lacks.
  "X does not handle Y" needs a reason the reader can check.

## Tense, person, and typography

Evidence comes from the submitted sources of the five papers, with comments
excluded.
The counts depend on which files are included, so treat them as approximate.
Follow the template and the paper's established forms where they differ.

| convention | what the repos do | evidence |
|-|-|-|
| tense for method and results | present dominates in every paper (counts range from 53 present vs. 2 past to 69 vs. 3, by file set) | "we run each experiment at least three times" (paper E) |
| tense for one completed observation | past, in one method or result sentence (the other past-tense hits are AI-use acknowledgements) | "we measured 7.7M promotions under PACT" (paper E) |
| tense for design and figures | present | "The \sys{} prototype uses Intel PEBS/LDLAT" (paper E). "Figure~\ref{fig:cat-sens} shows three representative results" (paper E) |
| person | "we" for the authors' actions, the system by name or macro | `\newcommand{\sys}{Name\xspace}` (paper E). `\def \sys {{\textsc{Name}}\xspace}` (paper D) |
| unit spacing | thin space in paper B, paper C, and paper E. Normal space in paper A. Paper D mixes normal spaces and no space | `4\,KiB` (paper B). `4 KiB base pages` (paper A). `writes 4\,KB` (paper C). `32GB DRAM` (paper D) |
| KB vs. KiB | both appear, KB more often in numeric literals | the frequency does not say which unit was meant, so check before changing |
| citation spacing | `~\cite` in roughly 83% to 90% of direct citations, depending on the file set. Paper D is mixed | `CPU2017~\cite{speccpu2017.web}` (paper B) |
| references | `Figure~\ref{...}`. Paper D uses standalone `\autoref`, which needs no tie | `Figure~\ref{fig:instruments}` (paper B) |
| e.g. | followed by a comma in prose. The literal form and the `\eg` macro are about equally common (13 and 14 in one count), and most macro uses are in paper D | `(\eg, matrix multiplication, 2D convolution)` (paper D) |
| compound modifiers | hyphenated before a noun | `dual-socket` (paper D), `single-threaded` (paper A) |
| heading case | title case in all five papers. Paper C run-in leads use sentence case | `\subsubsection{SSA-Level Optimization}` (paper D) |

One form per paper is the rule that survives the inconsistency. A polish pass
that finds `4 KiB` and `4\,KiB` in the same paper picks the dominant form and
reports the change. It does not import another paper's convention.

## Information order (outside guidance)

From Gopen and Swan, "The Science of Scientific Writing" (American Scientist
78, 1990). This guidance does not come from the repos. They write that "None of these
reader-expectation principles should be considered 'rules.'" Apply them where
a sentence is hard to follow. The example sentences in this section are
constructed for illustration and are not quoted from the papers.

- Old before new. The start of a sentence links back to what the reader
  already has, and the end carries the new information and the emphasis. In
  "Promotions stall the CPU for 340 ms. That stall comes from page-table
  updates under the mmap lock.", the second sentence opens with "That stall",
  which the reader already has. Written as "Page-table updates under the mmap
  lock cause that stall", it opens with new material and leaves the link for
  the end.
- Subject near verb. "The policy, which samples PEBS records every 10 ms and
  ranks pages by their stall time over a sliding window, promotes" makes the
  reader hold "the policy" for 18 words. Move the clause after the verb or
  into its own sentence.
- The subject is whose story the paragraph follows. In a paragraph about what
  the kernel does, start with the kernel. In a paragraph that follows a page
  through migration, "The page is then copied to the fast tier" is the better
  sentence even though it is passive.
- Name a referent when two are plausible. "This" after a sentence with two
  candidate nouns becomes "This delay". After a sentence with one candidate,
  it stays.

## Contributions

- "We make three contributions:" attached to the end of the preceding paragraph,
  not a paragraph on its own (paper B blueprint). Adjust the count to the truth;
  exactly three is the common case (paper B review notes "exactly three items").
- Each bullet opens with "We" plus a precise verb ("systematically
  characterize", "design", "develop"), carries its numbers inline, has no bold
  label phrase, no section reference, no slogan. "A phenomenon. Disaggregation
  exposes ..." became "We show that disaggregation exposes" (paper C). "A
  systematic characterization of CXL-SSD performance" became "We systematically
  characterize CXL-SSD performance" (paper B).
- Each contribution names a claim and the evidence class that supports it; a
  single bullet "cataloguing eight findings" is "the second abstract problem"
  (paper B review notes).
- No defensive paragraph after the list.

## Design and implementation sections

- Problem, observation, design choice, implementation, evaluation, in that
  order. Define data structures and symbols before using them. Show what happens
  to an actual access or graph before generalizing (paper B).
- Separate design reasoning from Linux/Intel engineering detail (paper E,
  two reviewers). Formal design-section terms (CallState, SharedState) do
  not appear in abstract, intro, background, or conclusion (paper D lint, severity
  error).
- Explain why, not only what. A reviewer flagged a design description that
  said what the system does without saying why. One end-to-end worked example on one
  foreground/background pair or one program carries the design (paper E,
  paper D).
- An implementation paragraph lists components as a parallel noun list:
  "a paper D.accel("xpu", params) call in the DSL, a code emitter in the compiler,
  and a dispatcher in the runtime." (paper D).

## Evaluation

- Pose the questions in prose, not an itemize: "Our evaluation asks four
  questions: whether ..." (paper D).
- Platform paragraph says what runs where, not why that fidelity was needed:
  "The complete host, NVMe, FTL, flash, and firmware path runs in FEMU" replaced
  a paragraph beginning "Evaluating a full-stack ISC system requires both
  end-to-end system fidelity and component-level cycle accuracy." (paper D
).
- Every case where the system ties or loses gets a stated reason, noise or
  mechanism, with error bars (paper E reviewers). When neither has been
  measured, the text says the cause is unresolved. Baseline omissions are
  justified architecturally ("SoarAlto omitted, same global-MLP family as
  PACT").
- Define every policy or configuration that appears in a table column. Paper
  E's camera-ready plan added a definition for a policy that had appeared only
  as a column header. Define table symbols in the text. Reviewers of paper D
  could not tell two of its table symbols apart.
- Unify the normalization convention across subsections.
- A result sentence has one statistic phrasing; name the statistic once in
  Method and say "on average" thereafter (paper D).

## Limitations and conclusion

- Each limitation is one sentence, ending in what is planned when the authors
  have a plan: a 12-line write-intensive discussion became "Write-intensive
  workloads would benefit from write buffering and coalescing, both planned
  extensions." (paper D). Do not invent a planned extension to close the
  sentence. "We have not evaluated X" is a complete limitation.
  A 62-line bulleted limitations section became one paragraph (paper D).
- The conclusion argues rather than recaps (paper A : "costs land
  outside allocator code, the method replaces guessing, and the properties that
  decide a policy's sign are ones the application knows and has no way to
  express"). Make the point once (paper B conclusion 293 to 133 words). End on
  the open problem, not a summary.
- Finding boxes, if used, hold the rule alone ("averaging 41 words against 75",
  paper A) or are folded into prose entirely (paper E).

## Page-budget cuts

- Delete redundant subsections and floats before shrinking figures or fonts;
  "the extra page was granted for figure legibility" (paper E). Do not
  "compress explanations or shrink fonts, margins, or template spacing" (paper B).
- Merge tables with identical columns; drop a float whose numbers the prose
  already carries; fold a one-result subsection into the section its result
  supports.
- Archive deleted detail as a LaTeX comment with the commit that held it
  ("% Original caption detail", "git show <commit>:<file>").

## Rebuttals and shepherd responses

- Concede true points in the first sentence; refute misreadings firmly and
  politely; one hedge per claim; no defensive phrases such as "we do not hide"
  (paper E rebuttal strategy).
- Every "we will add X" is a hard deliverable the shepherd will diff against.
- Tag revised sentences to the reviewer question they answer
  (`\reviewer{Q}{B7,C2}`, paper D) and strip the markup before
  submission.
- Explain a marked-up PDF honestly: "Blue marks new sections and individual
  sentences whose claims changed. It does not mark the extensive editorial
  rewriting, which would make the document unreadable as a diff." (paper E
  shepherd response).

## Working method the authors converged on

- Proposals live in the LaTeX as colored text with their justification (paper C:
  blue = edit, orange = proposal, red = removal flag); accepted ones become
  plain text; all color is stripped before submission (paper C).
- A whole-paper read after every round, so every paragraph is reviewed after
  it is written (paper E).
- A model-produced rewrite is adopted paragraph by paragraph, never wholesale:
  "27 of 52 body paragraphs take the new version, the rest stay. An earlier
  wholesale splice silently dropped six control paragraphs and was reverted."
  (paper A).
- Track the de-AI lint until every P0 and P1 hit is fixed or kept with a
  named reason in the report, before calling a round done (paper A
  tracked it to zero).
