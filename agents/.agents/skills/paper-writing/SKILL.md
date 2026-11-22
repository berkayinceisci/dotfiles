---
name: paper-writing
description: Write, rewrite, tighten, or review systems-paper prose (abstract, introduction, design, evaluation, captions, contribution lists, related work, limitations, rebuttals and shepherd responses) so it reads as a human expert's argument rather than LLM output. Distilled from the lab's own paper-polish commits and reviewer feedback. Use whenever drafting or editing LaTeX paper text, writing captions or headings, answering reviewers, or asked to "polish", "tighten", "humanize", "de-jargon", or "make it sound less like AI".
---

# Paper writing

Making a draft sound human here means making it more literal, with named
mechanisms, measured quantities, and plain declarative sentences. A casual
tone is a different goal. The common LLM words (Notably, leverage, robust) are
the easy part, and the word list covers them. The harder problems are
metaphor presented as insight, "X, not Y" appositives, roadmap and
self-commentary sentences, lab-internal vocabulary, intensifier adverbs,
slogan headings, and claims that go beyond the evidence.

These are the lab's editorial preferences for systems papers. They do not
detect AI authorship. Venue rules, the template, and the paper's established
conventions take precedence over them.

Read `references/wordlist.md` before a sentence-level pass and
`references/structure.md` before a structural one.
`references/transformations.md` holds worked before/after examples, and
`references/reviewer-lessons.md` holds what reviewers and shepherds objected
to. The reference files also record where each rule came from. Look there
when a rule seems wrong for the case at hand. `scripts/prose-lint.sh` runs the
word-level checks.

## Which rule wins

1. The hard constraints below, and the bans on new em dashes, middle-dot
   separators, and the section 8 words in `references/wordlist.md`. These
   always apply.
2. The governing rule.
3. The numbered rules.
4. The quotas inside the rules ("at most one per section").
5. Lint hits.

## The governing rule: meaning first

The numbered rules are prompts to reread a sentence. They do not order a
rewrite of a sentence that already works. The hard constraints are different,
and they always apply.

Before cutting a word or clause, delete it in your head and ask whether a
fact, a condition, or a distinction disappears. If nothing disappears, cut it.
If something does, keep the information, and rewrite the sentence when that
states it more plainly. Keeping the information does not require keeping the
wording.

- A contrast stays when its negated half is the mistake a reader would
  otherwise make. In "only guarantees that A gets the lock, not that pred is
  still in the list", the second half is the content. In "because it is
  simpler, not because it is needed", the second half adds nothing.
- A technical term stays when it names a real distinction in this paper, even
  if a list below flags the word. Examples are "worker" in a thread-pool
  design, "significantly" after a statistical test, and "exactly" for an exact
  algorithm. Define the term for the intended reader.
- Emphasis comes from the end of the sentence (rule 12) or from a number. An
  intensifier adverb carries no emphasis of its own, so it does not survive
  this test.
- Let sentence length follow the content. A run of equal short sentences with
  every contrast removed is monotonous, and it hides which ideas depend on
  which. A sentence that states a cause and its effect may need two clauses.
  Split a sentence when it holds two claims. A word count alone is no reason
  to split.
- The quotas in the rules are defaults. Do not rewrite working sentences only
  to meet one.
- When you keep a flagged item, name the fact, condition, or distinction it
  carries in the change report.

## The rules

Each rule has one example here. The reference files hold many more.

1. **Literal over metaphor.** Name the mechanism and the quantity. A metaphor
   makes the reader work out what it means instead of reading the claim.
   "Merging is a lever the system has already pulled" became "Merging's
   contribution is already in every measurement". "Three different
   currencies" became "three separable costs". "The BG has to want the ways
   back" became "The BG must benefit from returned ways". Banned metaphor
   families are wall, price, tax, lever, subsidy, gift, currency, bill,
   bargain, purchase, bet, meter, crowd, funnel, and starve.

2. **No slogans, no aphorisms, no staged dialogue.** Headings, caption titles,
   run-in bold leads, and paragraph openers are noun phrases that name what is
   shown or done. "One Load, Three Costs" became a descriptive title, and
   "Charge the Execution That Pays" became "Accounting for the Whole
   Execution". "Three Ways a Write Path Fails" became "Occupancy, Service, and
   Dependency Limits". Delete fragments like "Same policy, same direction,
   opposite signs." and two-sentence reversals like "The device is not slower
   on the fabric. It is emptier." Delete rhetorical questions, one-word
   answers ("It can."), and staged objections ("True, and on a zoned drive
   nobody needs to").

3. **Delete scaffolding.** This covers roadmap sentences that restate nearby
   headings ("Section 4 develops these four components."), topic sentences
   that restate the paragraph after them ("GAPBS shows the favorable case"),
   paragraph-final restatements, and meta-announcements ("These controls
   answer different design questions.", "The contrast completes the
   intervention argument."). It also covers insight scaffolding. "However, the
   sweep yields two critical insights." became "Two results from the sweep
   guide the policy." An announcement survives only when its items follow
   immediately in the same paragraph ("Two consequences follow." then the two
   consequences).

4. **Cut the negative-parallelism habit.** This covers ", not X" appositives,
   "X rather than Y", "not X but Y", and defensive negations ("a fit, not a
   prediction", "we claim no novelty for this"). State what the thing is, and
   state separately what was not run. Allow at most one such line per paper as
   a deliberate signature ("a witness, not an oracle"). Use "rather than" at
   most once per section. Cleft reveals ("What fails is", "The reason is
   that", "It is the X that") and matched openers in adjacent bullets or
   sentences belong to the same family. Keep a contrast only when the negated
   half is the mistake a reader would otherwise make. Wordlist section 4a has
   examples.

5. **Strip intensifiers and hedge adverbs.** These include actually, exactly,
   genuinely, merely, essentially, precisely, quietly, simply, nevertheless,
   more importantly, vastly, just, explicitly, especially, accurately,
   completely, fundamentally, easily, seamlessly, by design, crucially,
   significantly, clearly, central, and critical. "sufficiently cache-elastic
   to exploit" became "able to exploit". The lint script also carries Matt
   Might's weasel-word list.

6. **Connectives: subordinate less, coordinate more.** "Since X, Y" and
   "Because X, Y" become "X, so Y". "While X, Y" becomes "X, but Y". Drop
   sentence-initial "Thus,", "Consequently,", "However,", "Together,",
   "Overall,", and "In sum", or move them mid-sentence ("therefore" after the
   verb). Rule 11 covers punctuation that does the same joining work.

7. **Verbs carry the sentence.** Restore verbs from nominalizations.
   "Repeated use must repay these preparation costs" became "Reordering should
   save more runtime than it takes". Replace light verbs and "allows/enables X
   to" with the agent as subject. "This affine model allows an operator to
   size" became "An operator can therefore size". Use the active voice where
   the actor matters. "Low L2 latency is misread as permission" became "It
   misreads low L2 latency as permission". Verbs that worked well include
   incurs, cuts, reserves, accounts for, partitions, reads, holds, matters,
   lowers, runs in, plans, coalesces, and settles.
   A sentence that describes a mechanism names what is acted on and the
   reference point of every relative position. "reads the identifier some
   edges ahead" leaves "ahead of what" open, and it makes the bare term
   "lookahead reads" parse as a plural noun. "the lookahead reads the
   identifier of a neighbor several edges further along the list and requests
   that neighbor's value before the loop reaches it" leaves nothing open.
   Prefer "only" before the main verb, and move it there during editing unless
   that changes the intended meaning or introduces ambiguity.

8. **Replace lab vocabulary by sense, not by substitution.** arm becomes
   control, build, configuration, or run. campaign becomes experiment or runs.
   cell becomes the allocator-workload combination, probe becomes experiment
   or test, intervention becomes optimization or change, worker becomes
   thread, census becomes count, and wall becomes throughput limit. Channel
   A/B/C becomes the named things, and a machine hostname becomes the target
   host or the initiator. A reader cannot tell whether a campaign is one run or
   six months.
   Define every term at first use, and add a terms table when more than a
   handful recur. Never presuppose an entity the reader has not met ("the two
   drives" before the setup). Keep one vocabulary throughout. Pick service or
   delivery, pooling or global MLP, and use it everywhere, including the
   title. The primary metric gets one name, defined once in the method section
   as what is timed ("traversal time, the wall-clock time of one kernel
   invocation on a loaded graph"). "elapsed time", "runtime", and "traversal
   time" for the same quantity is three names.
   Define a literature term the reader may not share ("lead time",
   "criticality", "hotness") in the sentence that first uses it, or replace it
   with the plain description ("issue the request early enough that the data
   arrive before the program needs them"). A term the author cannot paraphrase
   in one clause is not understood well enough to use. A proposal introduces
   no technique it does not need to state its hypotheses. If "sampled latency"
   or "scan-suppressed" appears in a hypothesis, either the hypothesis is
   about the method, which belongs in the plan, or the term leaked from the
   lab's own vocabulary. Replacement is by sense, so a listed word that carries
   a technical meaning in this paper stays and gets defined.

9. **Keep every number, and make each say what it measures.** Fidelity
   outranks tightening. Keep every number when polishing. When drafting, add a
   number only when it traces to a named source, and mark any other with
   `[[TODO: need source]]`.
   - Write plain digits, with no "~" and no "about" before an exact figure.
   - Ratios and speedups take at most two significant digits ("4x" not
     "4.0x", "1.3x"). Measured values keep the precision the evidence
     supports, and exact counts and identifiers are never rounded.
   - Use one metric per comparison and name the denominator ("in 39 of 42
     calibration cells", "NAND-read bytes are 94.6% of its CXL-read bytes").
   - Counts replace "mostly" and "some" ("372 of 382 application points").
   - A human-scale phrase can replace false precision ("one in 8,000",
     "essentially zero" for 0.0000152). Round a measured value, or replace it
     with such a phrase, only when the authors have approved it. Otherwise
     propose the change in the report and leave the number in place.
   - Numbers appear as parenthetical support after the claim. They are not
     the claim. Headline results are speedups against a named baseline.
   - Numeric ranges take an en dash ("16--45 ms", "8--64 GiB"), never "16 to
     45 ms". "from 5.6 to 13.2" stays only for a change along an axis.

10. **Claims calibrated to evidence, caveats kept.** Use causal verbs only for
    controlled interventions. Choose "shows", "establishes", "demonstrates",
    "is consistent with", or "we infer" by the claim's scope, the controls,
    the uncertainty, and the alternative explanations left open. Run count
    alone does not decide it. Repeated runs of an uncontrolled comparison
    still only suggest, and one careful measurement can show a narrow fact.
    Upgrade the verb when the evidence lands.
    Put the caveat in the same sentence as the claim or the next one. Never
    move it to a separate disclaimer paragraph, and never repeat it three
    times. Use one hedge per claim. Search for unsupported absolutes such as
    all, always, never, guarantee, exact, perfect, undocumented, the first, no
    existing, beyond the reach, and state-of-the-art. Prefer "to our
    knowledge" and bounded comparisons ("over the best prior ISC system per
    workload"). Related work argues from the paper's own counterexamples.
    Saying "we do not claim" is no argument. Do not enter novelty contests the
    paper does not need to win.

11. **Punctuation does not do the joining.** A recurring mid-sentence colon
    that introduces an explanation ("The cache itself works: the device
    reports") hides how the two halves relate. Keep a colon before a list or a
    definition, at most one per paragraph, and none in the abstract. Otherwise
    end the sentence, or join the halves with ", so" or "because". A semicolon
    between two clauses does the same work and is rationed the same way. Two
    short sentences are clearer than one spliced sentence. Do not add em
    dashes, and turn existing ones into commas, ", so", or a new sentence.
    An aside is a parenthetical clause that comments on its sentence, such as
    "(which we revisit later)". Asides become commas or their own sentence.
    Parenthetical numbers after a claim, and a configuration in parentheses at
    the end of a caption, are not asides and stay.
    The middle dot used as a separator is banned. That covers " · " in a
    caption, legend, heading, or author line, `\textperiodcentered`, and
    `$\cdot$` between words. Replace it with punctuation that names the
    relationship. Use a phrase or trailing parentheses in a caption, "=" for
    key-value pairs, "vs." or a slash for alternatives, a line break in a
    diagram node, and a new column in a table when the two items are separate
    data fields. The full table is in `references/wordlist.md`, next to the
    em-dash note.

12. **Order information for the reader (heuristic).** These are tendencies of
    reader expectation, not fixed rules. Use them when a sentence is hard to
    follow.
    - Start a sentence with what the reader already has from the previous
      sentence. End it with the new point, because readers stress the end of
      a sentence.
    - Make the subject the thing whose story the paragraph follows. Usually
      that is the component or person that acts, as in rule 7. When the
      paragraph follows the object, a passive sentence keeps the story
      continuous and is the better choice.
    - Put the verb right after its subject. A long clause between them reads
      as an interruption.
    - When a sentence opens with "This" or "These" and the previous sentence
      offers two plausible referents, name the referent ("This delay", "This
      policy"). When only one reading is possible, the bare pronoun is fine.

13. **Tense, person, and typography follow the paper.** Use the present tense
    for the design, the method, the results, and what a figure shows ("we run
    each experiment at least three times"). The past tense fits one completed
    observation ("we measured 7.7M promotions under PACT"), though this
    convention rests on little evidence. "We" is the authors, and the system is
    "it" or its name. Papers differ on unit spacing and on KB versus KiB.
    Follow the template and the forms the paper already uses, and make them
    consistent within the paper. Check what a unit means before changing its
    notation. The checklist is in `references/structure.md`, in the section
    "Tense, person, and typography".

## Structural rules in brief

- **Insight-first paragraphs.** The heading or first sentence is the claim,
  and the numbers follow in parentheses. Every loss gets a mechanism, or the
  text says the cause is unresolved. Where the rival wins is stated. "1:1
  ratio." became "Placement quality, not sampling rate, separates the
  systems." Make one claim per paragraph. State the thesis once instead of
  re-deriving it in every section. Carry one concrete example through the
  paper.
- **Explain graphs instead of narrating them.** A recital of fifteen
  normalized numbers with one explanatory clause narrates. Captions say what
  is plotted, the units, and the legend keys in two or three lines. Results
  live in the body.
- **Sentences: one claim each.** A sentence over about 40 words is a prompt
  to reread. Split it into setup, mechanism, and consequence when it carries
  more than one claim. Leave it when its clauses make one claim.
- **Contributions.** "We make three contributions:" ends the preceding
  paragraph. Each bullet is "We" plus a precise verb, with numbers inline, no
  bold slogan labels, and no section references.
- **Abstract.** Problem, insight, motivated design, complementary mechanisms,
  and one results sentence against a named baseline, under 200 words, with no
  generic significance line.
- **The conclusion argues and does not recap.** Each limitation takes one
  sentence. End with a planned extension only when the authors have one. Do
  not invent future work to close the sentence.

`references/structure.md` has the details, templates, and blueprints for the
abstract, introduction, background, and related work.

## Drafting procedure

For a section or paper with no text yet.

1. **Name the reader and the questions.** Say who the section is for, such
   as a storage reviewer or a non-specialist on the program committee. State
   the questions it answers. If they do not share one argument, consider
   separate sections. A combined background and related-work section that
   serves one argument can stay combined.
2. **Map claims to evidence.** List each claim with the figure, table,
   measurement, or citation that supports it. Rule 10 requires narrowing a
   claim to the scope its evidence supports. Hiding a gap is different. A
   claim that needs support you do not have gets `[[TODO: need source]]` in
   the draft and a line in the report.
3. **Outline the argument** as one sentence per paragraph. Each sentence is
   the claim its paragraph makes, in the order a reader needs. Check the
   outline against `references/structure.md` for that section type.
4. **Write the prose** from the outline under the governing rule and the
   numbered rules. Then run the polish procedure below on the result.
5. **Report** the claims left unsupported, the terms the draft introduced,
   and every number it needed that the sources did not give.

## Polish procedure

1. **Read the whole section with its neighbors** before editing anything.
   Identify the question each paragraph answers and what the next paragraph
   needs from it. Fix structural problems first (a missing premise, a cold
   topic switch, a claim without a mechanism, a repeated caveat), then the
   wording. Adding "therefore" cannot repair a missing premise. Reorder,
   merge, or cut instead.
2. **Sentence pass** against `references/wordlist.md`. Check metaphor,
   slogans, scaffolding, negative parallelism, intensifiers, connectives,
   nominalizations, lab jargon, and openers.
3. **Run the lint** with `scripts/prose-lint.sh -v path/to/*.tex`. Each hit
   is a prompt to reread, not a verdict.
4. **Preservation check.** Diff before and after. Every number, citation,
   label, ref, and figure and table environment survives unless the brief says
   otherwise. Every caveat survives. If a cut fact moves, name where it now
   lives.
5. **Build and confirm the text reached the PDF.** Run
   `scripts/check-render.py <doc-dir>` after every edit. It strips comments
   and markup from the section sources and reports any run of four words
   missing from the pdftotext output. A hit is a suspected loss to inspect
   against the PDF, such as text commented out, swallowed by a macro, or lost
   in a wrap or a join. Fix it before anything else. Page count, caption line
   counts, undefined references, and 80-column wrapping come after this
   check, never instead of it, because a page count alone misses a sentence
   lost into a LaTeX comment.
   The check is partial. It skips figure, table, tabular, and TikZ
   environments, captions included, and fragments under four words. It finds
   files only through `\input{...}` lines in `main.tex`, skips the z-,
   macros, title, bib, and todo files, and does not follow `\include`,
   conditional inputs, or nested inputs. Zero runs checked means the check was
   inconclusive. Text an edit newly commented out shows up only in the diff
   from step 4. Read captions and short sentences against the PDF by hand.
6. **Report** substantive changes separately from wording changes, and say what
   a prose edit cannot fix, such as a missing experiment or a positioning
   problem.

## Hard constraints

- Never drop a number, citation, or caveat to make text shorter. If space
  forces a choice, cut evidence before cutting caveats.
- Never strengthen a claim by rewriting it. "determine" is not "predict", and
  "rules determine" became "choices shape".
- Never use a term before it is defined, and never let formal terms from the
  design section leak into the abstract, introduction, or conclusion.
- Never delete LaTeX comments. Archive cut detail as a comment that points to
  the commit that held it. Never add a comment inside a paragraph, because a
  comment line between two sentences is one rewrap away from swallowing the
  next sentence. Provenance notes and open questions go in the project's todo
  file or docs. Archived cuts go at the end of the file or above the
  paragraph, each on its own line ending in a newline.
- Do not trim for a page limit while the text is still being worked on.
  Fitting the page limit is a separate, final step the author asks for.
  Trimming during drafting is where the risky edits come from.
- Do not use em dashes in new prose. Do not use the middle dot (" · ") as a
  separator anywhere in the paper. Do not use a colon as the default joiner
  between a claim and its explanation (rule 11). Write `Figure~\ref{fig:x}a`,
  never `Figure 5[a]`.
- Name machines by role, never by hostname, anywhere that reaches the PDF.
- The acknowledgement reads "We used Claude Code and ChatGPT to assist with
  code and writing. The work is otherwise the authors' own."

## Commit messages for polish commits

Say what was cut and why, and name the pattern ("repeated ', not X'
appositives", "topic sentences that restate the paragraph following them",
"lab-notebook vocabulary"). State the verification ("nothing dropped against
the pre-round source", "all 29 numbers trace to the body verbatim", "body
stays at 11 pages"). Record rejected proposals too, so the next pass does not
reintroduce them.

## Revising this skill

Keep provenance in the reference files. This file states the rules, with
short examples and no citations, and marks a rule "(heuristic)" when the
papers give it no direct evidence.

Agents imitate the prose of their instructions, so this file follows its own
rules outside quoted examples. After a revision, lint the skill and run the
lint's fixture test.

```
scripts/prose-lint.sh -c negpar,colon,semicolon,weasel,emdash SKILL.md references/*.md
scripts/tests/run.sh
```
