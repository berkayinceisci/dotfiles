---
name: paper-writing
description: Write, rewrite, tighten, or review systems-paper prose (abstract, introduction, design, evaluation, captions, contribution lists, related work, limitations, rebuttals and shepherd responses) so it reads as a human expert's argument rather than LLM output. Distilled from the writing-polish commits of five lab papers (ASPLOS'27 allochar, FAST'27 cxlssd, FAST'27 dst, FAST'27 epic, SOSP'26 tierce). Use whenever drafting or editing LaTeX paper text, writing captions or headings, answering reviewers, or asked to "polish", "tighten", "humanize", "de-jargon", or "make it sound less like AI".
---

# Paper writing

This skill records what the lab's own polish commits actually changed when a
draft was made ready for submission. Every rule below was extracted from a
before/after diff or from an author's commit message; the reference files quote
the originals with repository and commit hash so a rule can be checked against
its source.

Read `references/wordlist.md` before any sentence-level pass and
`references/structure.md` before any structural one. `references/transformations.md`
is the worked-example bank. `references/reviewer-lessons.md` is what reviewers and
shepherds punished. `scripts/prose-lint.sh` mechanizes the word-level checks.

## What "human" meant in these papers

The single most consistent finding across all five repositories: the humanizing
passes made the text **more literal, not more casual**. Metaphor, aphorism,
rhetorical staging, and slogan headings were the things removed. The register
that survived is plain, declarative, concrete, and specific about what was
measured. "Sounding human" is not a voice to adopt. It is the absence of
performance: no cleverness, no drama, no hedging ritual, no scaffolding, and
every number saying what it measures.

The classic LLM tells (Notably, Importantly, leverage, novel, robust, It is worth
noting, Moreover/Furthermore stacking) appeared zero times in the removed text of
four of the five repos. They were never there. What the authors actually cut was
subtler and is what this skill targets: metaphor dressed as insight, "X, not Y"
appositives, roadmap and self-commentary sentences, lab-internal vocabulary,
intensifier adverbs, slogans as headings, and claims that outran the evidence.

## The rules

Each rule has one example here; the reference files hold dozens more.

1. **Literal over metaphor.** Name the mechanism and the quantity. A metaphor
   makes the reader work out what it means instead of reading the claim.
   "Merging is a lever the system has already pulled" became "Merging's
   contribution is already in every measurement" (dst 8b37c39). "Three different
   currencies" became "three separable costs" (cxlssd 0e5f15c). "The BG has to
   want the ways back" became "The BG must benefit from returned ways" (tierce
   dde0fd9). Banned metaphor families: wall, price, tax, lever, subsidy, gift,
   currency, bill, bargain, purchase, bet, meter, crowd, funnel, starve.

2. **No slogans, no aphorisms, no staged dialogue.** Headings, caption titles,
   run-in bold leads, and paragraph openers are noun phrases that name what is
   shown or done. "One Load, Three Costs" became a descriptive title; "Charge the
   Execution That Pays" became "Accounting for the Whole Execution" (cxlssd
   6ad4b77). "Three Ways a Write Path Fails" became "Occupancy, Service, and
   Dependency Limits" (dst). Delete fragments like "Same policy, same direction,
   opposite signs." and two-sentence reversals like "The device is not slower on
   the fabric. It is emptier." Delete rhetorical questions, one-word answers
   ("It can."), and staged objections ("True, and on a zoned drive nobody needs
   to").

3. **Delete scaffolding.** Roadmap sentences that restate nearby headings
   ("Section 4 develops these four components."), topic sentences that restate
   the paragraph following them ("GAPBS shows the favorable case"),
   paragraph-final restatements, meta-announcements ("These controls answer
   different design questions.", "The contrast completes the intervention
   argument."), and insight scaffolding ("However, the sweep yields two critical
   insights." became "Two results from the sweep guide the policy."). The test
   from allochar: cut any sentence whose deletion loses no information. An
   announcement survives only when its items follow immediately in the same
   paragraph ("Two consequences follow." then the two consequences).

4. **Kill the negative-parallelism tic.** ", not X" appositives, "X rather than
   Y", "not X but Y", and defensive negations ("a fit, not a prediction", "we
   claim no novelty for this") are the most-flagged pattern in the allochar
   de-AI lint. State what the thing is; state separately what was not run. Allow
   at most one such line per paper as a deliberate signature ("a witness, not an
   oracle" was kept, 51 others were rewritten). Vary "rather than" to at most
   one per section. The same family: cleft reveals ("What fails is", "The
   reason is that", "It is the X that") and matched openers in adjacent bullets
   or sentences. Keep a contrast only when the negated half is the mistake a
   reader would otherwise make; see wordlist section 4a.

5. **Strip intensifiers and hedge adverbs.** actually, exactly, genuinely,
   merely, essentially, precisely, quietly, simply, nevertheless, more
   importantly, vastly, just, explicitly, especially, accurately, completely,
   fundamentally, easily, seamlessly, by design, crucially, significantly,
   clearly, central, critical. "sufficiently cache-elastic to exploit" became
   "able to exploit". Also the Matt Might weasel list in the lint script.

6. **Connectives: subordinate less, coordinate more.** "Since X, Y" and "Because
   X, Y" become "X, so Y". "While X, Y" becomes "X, but Y". Sentence-initial
   "Thus,", "Consequently,", "However,", "Together,", "Overall,", "In sum" are
   dropped or moved mid-sentence ("therefore" after the verb). Colons are
   rationed: a mid-sentence colon that introduces an explanation ("The cache
   itself works: the device reports") is the same reflex as the em dash and
   reads as model output when it recurs. Keep a colon only before a list or
   a definition, at most one per paragraph and none in the abstract;
   otherwise end the sentence or join with ", so" or "because". A
   semicolon between two clauses is the same reflex in a different glyph
   and is rationed the same way; two short sentences beat one spliced
   one. Em dashes: do not add them; convert existing ones to commas,
   ", so", or a new sentence. Parenthetical asides become commas. The
   middle dot as a separator (" · " between items in a caption, legend,
   heading, or author line; `\textperiodcentered`; `$\cdot$` between
   words) is the same tell in another glyph; use a comma, a semicolon, or
   separate lines.

7. **Verbs carry the sentence.** Restore verbs from nominalizations ("Repeated
   use must repay these preparation costs" became "Reordering should save more
   runtime than it takes"). Replace light verbs and "allows/enables X to" with
   the agent as subject ("This affine model allows an operator to size" became
   "An operator can therefore size"). Passive to active where the actor matters
   ("Low L2 latency is misread as permission" became "It misreads low L2 latency
   as permission"). Preferred verbs seen repeatedly: incurs, cuts, reserves,
   accounts for, partitions, reads, holds, matters, lowers, runs in, plans,
   coalesces, settles. A sentence that describes a mechanism names what is
   acted on and the reference point of every relative position: "reads the
   identifier some edges ahead" leaves ahead-of-what open and makes the
   bare term "lookahead reads" parse as a plural noun; "the lookahead reads
   the identifier of a neighbor several edges further along the list and
   requests that neighbor's value before the loop reaches it" does not
   (agos-project 2026-11-01).

8. **Replace lab vocabulary by sense, not by substitution.** arm (control, build,
   configuration, run), campaign (experiment, runs), cell (allocator-workload
   combination), probe (experiment, test), intervention (optimization, change),
   worker (thread), census (count), wall (throughput limit), Channel A/B/C (the
   named things), machine hostnames (the target host, the initiator). A reader
   cannot tell whether a campaign is one run or six months. Define every term at
   first use; add a terms table when more than a handful recur; never presuppose
   an entity the reader has not met ("the two drives" before setup). One
   vocabulary throughout: pick service or delivery, pooling or global MLP, and
   use it everywhere including the title. The primary metric gets one name,
   defined once in Method as what is timed ("traversal time, the wall-clock
   time of one kernel invocation on a loaded graph"); "elapsed time",
   "runtime" and "traversal time" for the same quantity is three names
   (agos-project 2026-11-01). Literature terms the reader may not share
   ("lead time", "criticality", "hotness") are either defined in the
   sentence that first uses them or replaced by the plain description
   ("issue the request early enough that the data arrive before the
   program needs them"); a term the author cannot paraphrase in one clause
   is not understood well enough to use. A proposal introduces no technique it
   does not need to state its hypotheses: if "sampled latency" or
   "scan-suppressed" appears in a hypothesis, either the hypothesis is
   about the method, which belongs in the plan, or the term is a leak from
   the lab's own vocabulary (agos-project 2026-11-01).

9. **Numbers are sacred and must say what they measure.** A polish pass that
   dropped 28 numbers was reverted (allochar ed5109c); fidelity outranks
   tightening. Keep every number; add none. Plain digits (no ~, no "about" before
   an exact figure); two significant digits ("4x" not "4.0x"); one meter per
   comparison with the denominator named ("in 39 of 42 calibration cells",
   "NAND-read bytes are 94.6% of its CXL-read bytes"); counts replace
   "mostly/some" ("372 of 382 application points"); human-scale replaces false
   precision ("one in 8,000", "essentially zero" for 0.0000152). Numbers appear
   as parenthetical support after the claim, not as the claim. Headline results
   are speedups against a named baseline.
   Numeric ranges take an en dash, "16--45 ms" and "8--64 GiB", never
   "16 to 45 ms"; "from 5.6 to 13.2" stays only for a change along an axis
   (agos-project 2026-11-01). "Only" goes before the verb it limits: "a
   hardware prefetcher only requests addresses it can predict", not
   "requests only addresses" (agos-project 2026-11-01).

10. **Claims calibrated to evidence, caveats kept.** Causal verbs only for
    controlled interventions; "shows", "establishes", "demonstrates" only when
    the evidence is more than one run; "is consistent with", "we infer",
    "confirms" chosen by evidence grade and upgraded when the evidence lands.
    Caveat in the same or next sentence as the claim, never a separate disclaimer
    paragraph, never repeated three times. One hedge per claim. Search for
    unsupported absolutes: all, always, never, guarantee, exact, perfect,
    undocumented, the first, no existing, beyond the reach, state-of-the-art.
    Prefer "to our knowledge" and bounded comparisons ("over the best prior ISC
    system per workload"). Related work argues from the paper's own
    counterexamples, not from "we do not claim"; do not enter novelty contests
    the paper does not need to win.

## Structural rules in brief

- **Insight-first paragraphs.** The heading or first sentence is the claim; the
  numbers follow in parentheses; every loss gets a mechanism; where the rival
  wins is stated. "1:1 ratio." became "Placement quality, not sampling rate,
  separates the systems." (tierce 9340bcb). One claim per paragraph. Thesis
  stated once, not re-derived per section. One concrete example carried through.
- **Explain, do not narrate, graphs.** A recital of fifteen normalized numbers
  with one explanatory clause is what the SOSP shepherd flagged. Captions say
  what is plotted, units, and legend keys in two or three lines; results live in
  the body.
- **Sentences: one clause each.** Split anything over about 40 words into
  setup, mechanism, consequence.
- **Contributions:** "We make three contributions:" attached to the preceding
  paragraph; each bullet "We" plus a precise verb, numbers inline, no bold
  slogan labels, no section references.
- **Abstract:** problem, insight, motivated design, complementary mechanisms,
  one results sentence against a named baseline. Under 200 words. No generic
  significance line.
- **Conclusion argues; it does not recap.** Limitations: one sentence each,
  ending in what is planned.

Details, templates, and the abstract/intro/related-work blueprints are in
`references/structure.md`.

## Polish procedure

1. **Read the whole section with its neighbors** before editing anything.
   Identify the question each paragraph answers and what the next paragraph
   needs from it. Structural problems first (missing premise, cold topic switch,
   claim without mechanism, repeated caveat); wording second. Adding "therefore"
   cannot repair a missing premise; reorder, merge, or cut instead.
2. **Sentence pass** against `references/wordlist.md`: metaphor, slogans,
   scaffolding, negative parallelism, intensifiers, connectives, nominalizations,
   lab jargon, openers.
3. **Run the lint:** `scripts/prose-lint.sh -v path/to/*.tex`. Review each hit;
   it is a prompt, not a verdict.
4. **Preservation check.** Diff before and after: every number, citation,
   label, ref, figure and table environment survives unless the brief says
   otherwise. Every caveat survives. If a cut fact is moved, name where it now
   lives.
5. **Build and verify the text reached the PDF.** Run
   `scripts/check-render.py <doc-dir>` after every edit: it strips comments
   and markup from the section sources and reports any run of four words
   that is absent from the pdftotext output. A hit means text was
   commented out, swallowed by a macro, or lost in a wrap or a join; fix
   it before anything else. Page count, caption line counts, undefined
   references and 80-column wrapping come after that check, never
   instead of it. A page-count check alone let a sentence opening vanish
   into a LaTeX comment unnoticed (agos-project 2026-11-01).
6. **Report** substantive changes separately from wording changes, and say what
   a prose edit cannot fix (a missing experiment, a positioning problem).

## Hard constraints

- Never drop a number, citation, or caveat to make text shorter. Cut evidence
  before cutting caveats if space forces a choice ("I would rather cut evidence
  than cut caveats", cxlssd rewrite-loop r7).
- Never strengthen a claim by rewriting it. "determine" is not "predict";
  "rules determine" became "choices shape".
- Never add a term before it is defined, or let design-section formal terms
  leak into the abstract, intro, or conclusion (epic's linter makes this an
  error).
- Never delete LaTeX comments; archive cut detail as a comment with a pointer
  to the commit that held it rather than losing it. But never add a comment
  inside a paragraph: a comment line between two sentences is one rewrap
  away from swallowing the next sentence. Provenance notes and open
  questions go in the project's todo file or docs, and archived cuts go at
  the end of the file or above the paragraph, each on its own line ending
  in a newline.
- Do not trim for a page limit while the text is still being worked on.
  Fitting passes are a separate, final step the author asks for; trimming
  during drafting is where the risky edits come from.
- Do not use em dashes in new prose, do not use the middle dot (" · ") as
  a separator anywhere in the paper, and do not use a colon as the default
  joiner between a claim and its explanation (rule 6). Do not use
  `Figure 5[a]`; use
  `Figure~\ref{fig:x}a`.
- Machines by role, never by hostname, anywhere that reaches the PDF.
- Acknowledgement wording that the authors settled on: "We used Claude Code and
  ChatGPT to assist with code and writing. The work is otherwise the authors'
  own."

## Commit messages for polish commits

The repos' own convention: say what was cut and why, name the pattern
("repeated ', not X' appositives", "topic sentences that restate the paragraph
following them", "lab-notebook vocabulary"), and state the verification
("nothing dropped against the pre-round source", "all 29 numbers trace to the
body verbatim", "body stays at 11 pages"). Record rejected proposals too, so the
next pass does not reintroduce them.
