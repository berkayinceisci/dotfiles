# Word and phrase list

Every entry in sections 1 through 7 was removed or replaced in a polish commit of
one of the five source repositories (paper A, paper B, paper C, paper D, paper E), or is
named in an author's commit message, lint, or review prompt. Counts are
"removed/added" across polish diffs where the mining agents recorded them.
Section 8 is supplementary: the standard LLM tells, which never appeared in
these papers but which the user wants excluded.

Replace **by sense**, not by substitution (paper B). The same banned word
takes different replacements in different sentences.

## 1. Metaphor nouns and verbs (replace with the literal quantity or mechanism)

| banned | observed replacement | source |
|-|-|-|
| wall (12 to 5) | throughput limit, delivery limit | paper C  |
| price, prices, priced (25 to 9) | measures, cost | paper C  |
| tax (6 to 2) | cost; keep only as the cited term "datacenter tax" | paper C, paper A |
| lever (13 to 6) | mechanism, setting, knob when literal | paper C |
| subsidy, gift, emptier, pulled, buys | contribution, effect, positive, enabled, supplies | paper C,  |
| starve, starved (13 to 0) | occupancy-limited | paper C |
| crowd, funnel, grip, loom, all along | the named quantity | paper C |
| currencies (17 to 0) | costs, quantities | paper B  |
| bet, bets, meter, meters, payer | assumptions, count of events times cost per event | paper A,  |
| purchase, bill, bargain, want (the BG has to want) | trade, cost, saving, must benefit from | paper E,  |
| trusts no passive signal | periodically removes one way and retains the release only when | paper E  |
| visually appealing sawtooth | reallocates constantly | paper E |
| bridges (compiler bridges X and Y) | lowers X into Y | paper D  |
| patchwork | single-layer solutions | paper D  |
| beyond the reach of | that prior systems cannot express | paper D  |
| expose (capacity) | serve, expand | paper B |
| half again as much | the exact percent | paper B  |
| finishes sooner | runs faster | paper B |
| quietly, silently (converts, contributing) | drop the adverb | paper C |

## 2. Intensifiers and hedge adverbs (delete; occasionally replace with a count)

actually (4 to 0), exactly (4 to 0), genuinely (2 to 0), merely, essentially,
precisely, quietly, simply, nevertheless, more importantly, vastly, just,
explicitly, especially, accurately, completely, massively, fundamentally, easily,
seamlessly, by design, crucially (7 to 1), significantly (6 to 3), clearly,
obviously, central (the central challenge), critical (critical insights),
dimensionless, additional (when it adds nothing), huge, tiny, remarkably,
surprisingly, interestingly, substantially, relatively, extremely, quite, very,
fairly, mostly, largely, many, various, several, few, vast, excellent.

The last fourteen are Matt Might's weasel list, which paper A runs as
the lint script's weasel list. "many", "several", "most" become counts: "372 of 382
application points have at least two allocators within 5%".

Examples: "It is especially effective for fs_mark" became "It suits fs_mark"
(paper C). "a mechanism that never reverses anywhere in the suite" became
"never reverses in our suite" (paper A). "can also be easily extended" became
"can be extended to priority-based or QoS-aware policies" (paper D).

## 3. Connectives and sentence openers

| pattern | replacement | source |
|-|-|-|
| Thus, (24 to 7) | ", so" joining the previous sentence | paper E |
| Consequently, (20 to 2) | "therefore" after the verb, or ", so" | paper E |
| However, (21 to 3) | drop, or ", but" | paper E |
| Since X, Y / Because X, Y | X, so Y | paper E,  |
| While X, Y (contrast) | X, but Y | paper E  |
| In particular, (6 to 2) | drop | paper E |
| Together, (5 to 0); Overall,; In sum (4 to 1); Moreover; Conversely; Note that | drop | paper D |
| That is (5 to 0); which is why (5 to 1); In other words | drop or colon | paper C |
| Here, "memory-bound" means | "memory-bound" means | paper E  |
| That number is misleading, though. | That number is misleading. | paper E |
| Nor is it simply X. (dangling after a cut) | The limit is not X. | paper C  |
| In this paper, we present (8 to 1) | We present | paper A, paper C |
| This paper makes three contributions: | We make three contributions: | paper B |
| Our key insight is that | state the insight as a declarative sentence | paper A  |
| The key question is: *italic question?* | We ask which ... and which ... | paper E  |
| Crucially, Figure N shows that X | X (Figure N). | paper E |
| We can observe that X | X | paper D  |
| Table N shows that these dimensions are fragmented | shows these dimensions fragmented | paper E |
| More strikingly, across three independent blocks, | drop | paper B |
| The exception is informative. / It can. / They establish the result that matters here | delete | paper B  |
| Two terms recur in the survey statistics. An item is | An item is | paper A  |
| Two responses follow. (transition stub) | delete | paper A  |
| Our evaluation aims to answer the following questions: itemize | Our evaluation asks four questions: whether ... | paper D  |
| After compilation, the system performs a series of coordinated steps to set up and launch offloading, as illustrated in Fig. | As illustrated in Fig., the compiler produces | paper D  |

Em dashes: paper B bans them outright; paper A's review prompt bans
them; paper C and paper E halved them, converting to commas, ", so", or a sentence
break. Do not add any. The same ban covers the middle dot as a separator,
as in "Workload · Config · Period", "Fig. 3 · Latency vs. load", or `$\cdot$`
between words. It applies in captions, legends, headings, author lines, and
tables. The dot stands in for a relationship the writer did not name, so the
replacement is the punctuation that names it.

| what the dot separates | replacement | example |
|-|-|-|
| facets of a caption or heading | rewrite as a phrase, or put the configuration in trailing parentheses | "Latency against load (4 KiB, random reads)" |
| key-value pairs | "=" with commas. For a long list of pairs, a small table or a sentence in the caption | "period = 1 ms, threads = 8" |
| two alternatives or two sides of a comparison | "vs.", "and", or a slash when space is tight | "FineList vs. LazyList", "read/write" |
| two words in a diagram or TikZ node | a line break (`\\`), a slash, or a compound when one word qualifies the other | paper E's "queue $\cdot$ tier budget" node (still in the figure) would become "queue\\tier budget" or "queue / tier budget" |
| author lines and footers | commas between names, superscripts for affiliations, a new line for the venue | |
| items inside a table cell | split into two columns when the items are separate data fields. A single compound value such as read/write can stay | |
| running text | no glyph; write the sentence | |

`\cdot` as multiplication in math stays. The bullet that `itemize` draws
marks list structure and stays. The slash is the fallback for labels with no
room for words, and the lint does not flag it.

## 4. Negative parallelism (the de-AI lint's P1 class)

Patterns: ", not X" appositive; "X, not Y"; "not X but Y"; "rather than"
(paper A 35/30, paper B 45/34, both called a "tic"); "X instead of Y" when used
as a reflex; "is not a Y, it is a Z".

| before | after | source |
|-|-|-|
| We claim observed mechanisms on these hosts, not a predictor: no held-out prediction test was run. | We claim observed mechanisms on these hosts; no held-out prediction test was run, so nothing here is a predictor. | paper A  |
| This is measured attenuation, not immunity: | This is measured attenuation when ...; it does not establish immunity, because | paper A  |
| What removing walks is worth is a fit, not a prediction. Over 140 Redis cells | What removing walks is worth is a fit over 140 Redis cells | paper A  |
| the gap is a witness, not an oracle, and it does not say which policy or why | the gap witnesses that fact without naming the policy behind it | paper A |
| so its lower BG cost comes from sacrificing FG protection, not from a better allocation. | so its lower BG cost comes from sacrificing FG protection. | paper E |
| use established techniques as probes rather than propose a new prefetcher | use established techniques to perturb different boundaries; we propose no new prefetcher | paper B |
| tcmalloc refers to this allocator rather than gperftools | tcmalloc means this allocator, not gperftools | paper A  |
| This is Little's law, and we claim no novelty for it. | deleted | paper C |
| We claim no new technique (three times in the intro) | once, at the experiment and in the limits | paper B  |

Allowed once per paper as a signature line ("a witness, not an oracle").

### 4a. Cleft reveals and matched openers (from a review of an LLM draft, 2026-11-09, outside the repos)

A cleft such as "What fails is the validation", "The reason is that", or "It
is the lock that" delays the point to set up a reveal. It belongs to the same
family as the ", not X" contrast. A pair of adjacent bullets or sentences
that open with the same words repeats a shape without adding information.
Both pass the deletion test only when the contrast is itself the fact.
Holding a lock versus holding the invariant is content. "because it is
simpler, not because it is needed" adds nothing.

| before | after |
|-|-|
| Fairness of the locks doesn't help because A is never stuck waiting. What fails is the validation. | Fairness of the locks does not help because A is never stuck waiting; the validation fails. |
| The reason is that pred may be unlinked between the read and the lock. | pred may be unlinked between the read and the lock. |
| because it's simpler, not because it's needed | for simplicity; the lock is not required for correctness |
| contains() would not be wait-free anymore. / contains() would not be read-only anymore. | contains() would lose both wait-freedom and its read-only property. (or keep both bullets and vary the opener) |

Keep: "only guarantees that A gets the lock, not that pred is still in the
list" (the negated half is the mistake the reader would make).

## 5. Lab-internal vocabulary (replace by sense; define what stays)

| internal word | replacements by sense | source |
|-|-|-|
| arm, arms (37 and 42 removed) | control (baseline), build (binary), configuration (setting), run (one execution). A shepherd noted the word is not common in systems venues | paper B, paper E |
| campaign, campaigns (36 and 46) | experiment; runs when a set of executions | paper B  |
| cell, cells | allocator-workload combination; the point | paper A  |
| probe, probes (21) | experiment, test; keep only for a microbenchmark | paper B  |
| intervention(s) (88) | optimization, change, experiment | paper B  |
| worker(s) (58) | thread(s), to match the figures | paper B |
| retained record, surviving record, retained cells, proxy falsification | drop the report-like framing | paper B |
| census | count; later re-adopted only as a defined term ("occupancy census") | paper C  |
| Channel A / B / C | allocator execution / kernel memory management / application memory access | paper A  |
| three-arm | three-way | paper B |
| pooling | global MLP, everywhere | paper E  |
| churn | convergence transient | paper E  |
| reconstructs (a signal) | estimates | paper E |
| latency-selective | latency-filtered | paper E |
| undocumented | under-documented (the filter is documented, its encoding is not) | paper E |
| Device truth | device-side measurements | paper C |
| progress (CPU makes progress) | retire instructions, execution time, accuracy of the computed scores | paper B |
| gmean / geometric-mean in prose | "on average", with the statistic named once in Method | paper D  |
| filter ratio / reduction ratio / filtering rate (three names) | filter selectivity, one name | paper D  |
| process block, block-to-block variation, three blocks | run each configuration three times, each in a fresh process and in rotated order; run-to-run variation; three rounds of fresh processes | project F |
| bear on, bears on (evidence that bears on a claim) | supports, qualifies, tests; name what the evidence does | project F |
| fix, fixed (a parameter, a setup, a choice) | choose, chosen, set, held constant; "fixed the programs" reads as repairing a defect | project F |
| gate, gated, gating (a policy that turns something off) | switch off, turn off after, disable in the phases where. Established hardware terms such as clock gating and power gating stay | project F, technical-term exception 2026-11-22 |
| gated, gating, phase-gated (prefetch policy) | turned off in the phases where it does not help; switched off after phase N | project F |
| hints, hints-off build, hints-on build | prefetch instructions; the changed loop without the prefetch instructions; with them | project F |
| stock (kernel, build) | the original program, the unmodified program | project F |
| always-on policy | lookahead left on for the whole run | project F |
| graph kernel (in a paper that also discusses the OS kernel) | graph program, graph workload | project F |
| scan-suppressed control, scanning suppressed | a run that starts from the same initial placement with migration turned off | project F |
| stall-based ranking, criticality | ranks pages by how long the CPU waits on them | project F |
| elapsed time / runtime / traversal time (three names for the primary metric) | traversal time, defined once in Method as the wall-clock time of one kernel invocation | project F |
| 15 to 30 us, regions of 8 to 64 GiB, one to sixteen threads (a range written with "to") | 15--30 us, 8--64 GiB, 1--16 threads; "from 5.6 to 13.2" only for a change along an axis | project F |
| placement of "only" | Prefer before the main verb, and move it there during editing unless that changes the intended meaning or introduces ambiguity. | project F; preference qualified 2026-11-19 |
| lead time (prefetching-literature term, undefined) | "issue the request early enough that the data arrive before the program needs them"; "requests issued too late" | project F |
| on/off/on triples (protocol name in a caption, undefined) | drop from the caption; if the drift bound matters, say "runs with the prefetchers on, off and on again in one session" in the body | project F |
| annotation (for the primitive) | primitive | paper D |
| r2d2, maven, hds07 (hostnames) | the target host, the initiator host, pair B | paper C  |
| Finding #N, Challenge N | descriptive names; fold finding boxes into prose | paper E |
| 4 GB when GiB is meant | 4 GiB | paper B |

Terminology hygiene: expand each acronym once at first use ("flash translation
layer (FTL)"), then never re-expand it (paper D  removed "A computational
storage device (CSD)" on second occurrence). Use `(\eg,` macros where the
template provides them. `\cite` takes a `~` before it.

## 6. Novelty and over-claim words (soften or bound)

| pattern | replacement | source |
|-|-|-|
| the first ISC system to | an ISC system that; or "To our knowledge, X is the first" | paper D  |
| no existing framework, beyond the reach of prior systems | not well supported by prior systems; that prior systems cannot express | paper D |
| state-of-the-art (as a baseline name) | the best prior system per workload, named | paper D, paper E audit plan |
| guarantee, exact, perfect, all, always | the bounded statement | paper E audit plan |
| novel (5 to 0), key insight, what is new is | Our contribution is | paper A, paper E |
| differential approach (10 to 3) | method | paper A |
| demonstrates, establishes, shows (evidence narrower than the claim, such as one run of an uncontrolled comparison) | is consistent with, suggests, or narrow the claim to what was measured | paper B review notes ("where the evidence is one run") |
| predict (from a fit) | determine; "choices shape" | paper B |
| Host runtime increases with cores because aggregate PCIe demand grows (unverified) | deleted | paper D  |
| 14x estimate nobody can locate in a figure | deleted | paper D  |
| Together, these results demonstrate that X and Y are essential to unlocking the full performance | deleted | paper D  |
| Takeaway: X brings huge performance benefits (box) | deleted | paper D  |
| the substrate differs fundamentally: those compilers | But those compilers | paper D |
| is a concurrent effort | Recently, Conduit also targets | paper D |
| tedious and error-prone | the measured consequence ("limits development productivity and achievable performance") | paper D  |

## 7. Self-commentary and praise (delete)

"One result forced us to sharpen what 'survives' means, and it is the paper's
most transferable finding." (paper C); "The important result does not require that
attribution" (paper B); "The contrast completes the intervention argument."
(paper B); "Size is the first thing a practitioner reaches for, and it is a weak
predictor." became "Graph size is a weak predictor." (paper B); "the paper's own
line"; "we do not hide" (paper E rebuttal rule: no defensive phrases); "smart
prefetching" (paper B blueprint: vague praise). The paper A review prompt ends
"No praise."

## 8. Supplementary: standard LLM tells (never observed in these papers; excluded on the user's request)

Words: delve, leverage, utilize, facilitate, enable (as a reflex; paper D cut
"enabl*" 17 to 5 and "allows" 7 to 0), robust, novel, seamless, seamlessly,
paradigm, unlock, harness, landscape, crucial, pivotal, holistic, showcase,
underscore, highlight (as a verb for "show"), testament, game-changer,
cutting-edge, comprehensive, multifaceted, myriad, tapestry, realm, foster,
navigate, streamline, revolutionize, transformative, groundbreaking, intricate,
nuanced, meticulous, elevate, empower, embark, journey, ensure (as filler).

Phrases: it is worth noting, it is important to note, in today's, plays a
crucial role, serves as, stands as, sheds light on, offers a glimpse, at its
core, to this end, in light of, taken together, ultimately, this is
particularly true, not only ... but also, a wide range of, in the realm of,
paves the way, opens the door, a double-edged sword, the elephant in the room,
in summary / in conclusion as section-final openers.

Shapes: triplets by reflex (three adjectives, three clauses, three bullets when
the content has two or four); a colon-headline sentence ("X: the Y that Z");
an explanatory colon as the default joiner ("The cache works: the device
reports 99.6% hits") more than once a paragraph;
a bold label followed by a colon at the start of every bullet; a paragraph that
ends by restating its first sentence; a question in the heading answered in the
first sentence; a "Not X. Y." two-beat reversal; em dashes as the default
punctuation; "Let's" and other reader address; hedging stacks ("may potentially
help to somewhat").

Replace each with the plain statement, and if there is no plain statement
underneath, delete the sentence.
