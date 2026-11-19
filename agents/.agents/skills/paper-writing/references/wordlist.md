# Word and phrase list

Every entry in sections 1 through 7 was removed or replaced in a polish commit of
one of the five source repositories (allochar, cxlssd, dst, epic, tierce), or is
named in an author's commit message, lint, or review prompt. Counts are
"removed/added" across polish diffs where the mining agents recorded them.
Section 8 is supplementary: the standard LLM tells, which never appeared in
these papers but which the user wants excluded.

Replace **by sense**, not by substitution (cxlssd b96b83c). The same banned word
takes different replacements in different sentences.

## 1. Metaphor nouns and verbs (replace with the literal quantity or mechanism)

| banned | observed replacement | source |
|-|-|-|
| wall (12 to 5) | throughput limit, delivery limit | dst aea4312 |
| price, prices, priced (25 to 9) | measures, cost | dst 8b37c39 |
| tax (6 to 2) | cost; keep only as the cited term "datacenter tax" | dst, allochar |
| lever (13 to 6) | mechanism, setting, knob when literal | dst |
| subsidy, gift, emptier, pulled, buys | contribution, effect, positive, enabled, supplies | dst 8b37c39, 831fb90 |
| starve, starved (13 to 0) | occupancy-limited | dst |
| crowd, funnel, grip, loom, all along | the named quantity | dst |
| currencies (17 to 0) | costs, quantities | cxlssd 0e5f15c |
| bet, bets, meter, meters, payer | assumptions, count of events times cost per event | allochar f14a958, 7a405a0 |
| purchase, bill, bargain, want (the BG has to want) | trade, cost, saving, must benefit from | tierce dde0fd9, f0ef62e |
| trusts no passive signal | periodically removes one way and retains the release only when | tierce 1c5406c |
| visually appealing sawtooth | reallocates constantly | tierce |
| bridges (compiler bridges X and Y) | lowers X into Y | epic 7c30ecd |
| patchwork | single-layer solutions | epic 7c30ecd |
| beyond the reach of | that prior systems cannot express | epic 20d9195 |
| expose (capacity) | serve, expand | cxlssd |
| half again as much | the exact percent | cxlssd 0e5f15c |
| finishes sooner | runs faster | cxlssd |
| quietly, silently (converts, contributing) | drop the adverb | dst |

## 2. Intensifiers and hedge adverbs (delete; occasionally replace with a count)

actually (4 to 0), exactly (4 to 0), genuinely (2 to 0), merely, essentially,
precisely, quietly, simply, nevertheless, more importantly, vastly, just,
explicitly, especially, accurately, completely, massively, fundamentally, easily,
seamlessly, by design, crucially (7 to 1), significantly (6 to 3), clearly,
obviously, central (the central challenge), critical (critical insights),
dimensionless, additional (when it adds nothing), huge, tiny, remarkably,
surprisingly, interestingly, substantially, relatively, extremely, quite, very,
fairly, mostly, largely, many, various, several, few, vast, excellent.

The last fourteen are Matt Might's weasel list, which allochar runs as
`bin/weasel.sh`. "many", "several", "most" become counts: "372 of 382
application points have at least two allocators within 5%".

Examples: "It is especially effective for fs_mark" became "It suits fs_mark"
(dst 12971f0). "a mechanism that never reverses anywhere in the suite" became
"never reverses in our suite" (allochar). "can also be easily extended" became
"can be extended to priority-based or QoS-aware policies" (epic 7196ba4).

## 3. Connectives and sentence openers

| pattern | replacement | source |
|-|-|-|
| Thus, (24 to 7) | ", so" joining the previous sentence | tierce |
| Consequently, (20 to 2) | "therefore" after the verb, or ", so" | tierce |
| However, (21 to 3) | drop, or ", but" | tierce |
| Since X, Y / Because X, Y | X, so Y | tierce 6cf3145, 720c104 |
| While X, Y (contrast) | X, but Y | tierce 40757d7 |
| In particular, (6 to 2) | drop | tierce |
| Together, (5 to 0); Overall,; In sum (4 to 1); Moreover; Conversely; Note that | drop | epic |
| That is (5 to 0); which is why (5 to 1); In other words | drop or colon | dst |
| Here, "memory-bound" means | "memory-bound" means | tierce d59f482 |
| That number is misleading, though. | That number is misleading. | tierce |
| Nor is it simply X. (dangling after a cut) | The limit is not X. | dst ac697fd |
| In this paper, we present (8 to 1) | We present | allochar a04ffca, dst |
| This paper makes three contributions: | We make three contributions: | cxlssd |
| Our key insight is that | state the insight as a declarative sentence | allochar 075bd93 |
| The key question is: *italic question?* | We ask which ... and which ... | tierce ee4b591 |
| Crucially, Figure N shows that X | X (Figure N). | tierce |
| We can observe that X | X | epic ae8a36d |
| Table N shows that these dimensions are fragmented | shows these dimensions fragmented | tierce |
| More strikingly, across three independent blocks, | drop | cxlssd |
| The exception is informative. / It can. / They establish the result that matters here | delete | cxlssd 357af8c |
| Two terms recur in the survey statistics. An item is | An item is | allochar 67484c9 |
| Two responses follow. (transition stub) | delete | allochar f14a958 |
| Our evaluation aims to answer the following questions: itemize | Our evaluation asks four questions: whether ... | epic ae0b7eb |
| After compilation, the system performs a series of coordinated steps to set up and launch offloading, as illustrated in Fig. | As illustrated in Fig., the compiler produces | epic 7196ba4 |

Em dashes: cxlssd AGENTS.md bans them outright; allochar's review prompt bans
them; dst and tierce halved them, converting to commas, ", so", or a sentence
break. Do not add any. The same goes for the middle dot as a separator
("Workload · Config · Period", "Fig. 3 · Latency vs. load", or `$\cdot$`
between words): never in captions, legends, headings, author lines, or
tables. Use a comma, a semicolon, a vertical bar in a table, or separate
lines. (`\cdot` as multiplication in math stays.)

## 4. Negative parallelism (the de-AI lint's P1 class)

Patterns: ", not X" appositive; "X, not Y"; "not X but Y"; "rather than"
(allochar 35/30, cxlssd 45/34, both called a "tic"); "X instead of Y" when used
as a reflex; "is not a Y, it is a Z".

| before | after | source |
|-|-|-|
| We claim observed mechanisms on these hosts, not a predictor: no held-out prediction test was run. | We claim observed mechanisms on these hosts; no held-out prediction test was run, so nothing here is a predictor. | allochar b420e09 |
| This is measured attenuation, not immunity: | This is measured attenuation when ...; it does not establish immunity, because | allochar b420e09 |
| What removing walks is worth is a fit, not a prediction. Over 140 Redis cells | What removing walks is worth is a fit over 140 Redis cells | allochar 44ca4fb |
| the gap is a witness, not an oracle, and it does not say which policy or why | the gap witnesses that fact without naming the policy behind it | allochar |
| so its lower BG cost comes from sacrificing FG protection, not from a better allocation. | so its lower BG cost comes from sacrificing FG protection. | tierce |
| use established techniques as probes rather than propose a new prefetcher | use established techniques to perturb different boundaries; we propose no new prefetcher | cxlssd |
| tcmalloc refers to this allocator rather than gperftools | tcmalloc means this allocator, not gperftools | allochar 7970d34 |
| This is Little's law, and we claim no novelty for it. | deleted | dst |
| We claim no new technique (three times in the intro) | once, at the experiment and in the limits | cxlssd 357af8c |

Allowed once per paper as a signature line ("a witness, not an oracle").

### 4a. Cleft reveals and matched openers (same family; from review of an LLM
draft, 2026-11-09, not from the repos)

A cleft ("What fails is the validation", "The reason is that", "It is the lock
that") stages a reveal; it is the ", not X" contrast with a drumroll. A pair of
adjacent bullets or sentences that open with the same words is symmetry for
its own sake. Both pass the deletion test only when the contrast is the fact
itself (holding a lock versus holding the invariant is content; "because it is
simpler, not because it is needed" is not).

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
| arm, arms (37 and 42 removed) | control (baseline), build (binary), configuration (setting), run (one execution); "arms is not a common vocabulary in our venues" | cxlssd b96b83c, tierce shepherd |
| campaign, campaigns (36 and 46) | experiment; runs when a set of executions | cxlssd b96b83c |
| cell, cells | allocator-workload combination; the point | allochar a04ffca |
| probe, probes (21) | experiment, test; keep only for a microbenchmark | cxlssd 357af8c |
| intervention(s) (88) | optimization, change, experiment | cxlssd 73668df |
| worker(s) (58) | thread(s), to match the figures | cxlssd |
| retained record, surviving record, retained cells, proxy falsification | drop the report-like framing | cxlssd |
| census | count; later re-adopted only as a defined term ("occupancy census") | dst 94f2df9 |
| Channel A / B / C | allocator execution / kernel memory management / application memory access | allochar 71c66a1 |
| three-arm | three-way | cxlssd |
| pooling | global MLP, everywhere | tierce 3cd1bc5 |
| churn | convergence transient | tierce 0ba1226 |
| reconstructs (a signal) | estimates | tierce |
| latency-selective | latency-filtered | tierce |
| undocumented | under-documented (the filter is documented, its encoding is not) | tierce |
| Device truth | device-side measurements | dst |
| progress (CPU makes progress) | retire instructions, execution time, accuracy of the computed scores | cxlssd |
| gmean / geometric-mean in prose | "on average", with the statistic named once in Method | epic cd72df2 |
| filter ratio / reduction ratio / filtering rate (three names) | filter selectivity, one name | epic aae35e2 |
| process block, block-to-block variation, three blocks | run each configuration three times, each in a fresh process and in rotated order; run-to-run variation; three rounds of fresh processes | agos-project 2026-11-01 |
| bear on, bears on (evidence that bears on a claim) | supports, qualifies, tests; name what the evidence does | agos-project 2026-11-01 |
| fix, fixed (a parameter, a setup, a choice) | choose, chosen, set, held constant; "fixed the programs" reads as repairing a defect | agos-project 2026-11-01 |
| gate, gated, gating (any sense) | switch off, turn off after, disable in the phases where; never use | agos-project 2026-11-01 |
| gated, gating, phase-gated (prefetch policy) | turned off in the phases where it does not help; switched off after phase N | agos-project 2026-11-01 |
| hints, hints-off build, hints-on build | prefetch instructions; the changed loop without the prefetch instructions; with them | agos-project 2026-11-01 |
| stock (kernel, build) | the original program, the unmodified program | agos-project 2026-11-01 |
| always-on policy | lookahead left on for the whole run | agos-project 2026-11-01 |
| graph kernel (in a paper that also discusses the OS kernel) | graph program, graph workload | agos-project 2026-11-01 |
| scan-suppressed control, scanning suppressed | a run that starts from the same initial placement with migration turned off | agos-project 2026-11-01 |
| stall-based ranking, criticality | ranks pages by how long the CPU waits on them | agos-project 2026-11-01 |
| elapsed time / runtime / traversal time (three names for the primary metric) | traversal time, defined once in Method as the wall-clock time of one kernel invocation | agos-project 2026-11-01 |
| 15 to 30 us, regions of 8 to 64 GiB, one to sixteen threads (a range written with "to") | 15--30 us, 8--64 GiB, 1--16 threads; "from 5.6 to 13.2" only for a change along an axis | agos-project 2026-11-01 |
| requests only addresses, recovers only 18%, is possible only when (only after the verb) | only requests addresses, only recovers 18%, is only possible when | agos-project 2026-11-01 |
| lead time (prefetching-literature term, undefined) | "issue the request early enough that the data arrive before the program needs them"; "requests issued too late" | agos-project 2026-11-01 |
| on/off/on triples (protocol name in a caption, undefined) | drop from the caption; if the drift bound matters, say "runs with the prefetchers on, off and on again in one session" in the body | agos-project 2026-11-01 |
| annotation (for the primitive) | primitive | epic terms_rules.yaml |
| r2d2, maven, hds07 (hostnames) | the target host, the initiator host, pair B | dst 6a3d82b |
| Finding #N, Challenge N | descriptive names; fold finding boxes into prose | tierce 9340bcb, cr-plan P3 |
| 4 GB when GiB is meant | 4 GiB | cxlssd |

Terminology hygiene: expand each acronym once at first use ("flash translation
layer (FTL)"), then never re-expand it (epic 95c9a74 removed "A computational
storage device (CSD)" on second occurrence). Use `(\eg,` macros where the
template provides them. `\cite` takes a `~` before it.

## 6. Novelty and over-claim words (soften or bound)

| pattern | replacement | source |
|-|-|-|
| the first ISC system to | an ISC system that; or "To our knowledge, X is the first" | epic 20d9195 |
| no existing framework, beyond the reach of prior systems | not well supported by prior systems; that prior systems cannot express | epic todo.tex |
| state-of-the-art (as a baseline name) | the best prior system per workload, named | epic, tierce audit plan |
| guarantee, exact, perfect, all, always | the bounded statement | tierce audit plan |
| novel (5 to 0), key insight, what is new is | Our contribution is | allochar, tierce |
| differential approach (10 to 3) | method | allochar |
| demonstrates, establishes, shows (one run) | is consistent with; one run suggests | cxlssd r8 |
| predict (from a fit) | determine; "choices shape" | cxlssd CHANGELOG |
| Host runtime increases with cores because aggregate PCIe demand grows (unverified) | deleted | epic 5bf784b |
| 14x estimate nobody can locate in a figure | deleted | epic 5bf784b |
| Together, these results demonstrate that X and Y are essential to unlocking the full performance | deleted | epic 5bf784b |
| Takeaway: X brings huge performance benefits (box) | deleted | epic ae8a36d |
| the substrate differs fundamentally: those compilers | But those compilers | epic 4492797 |
| is a concurrent effort | Recently, Conduit also targets | epic |
| tedious and error-prone | the measured consequence ("limits development productivity and achievable performance") | epic b80d592 |

## 7. Self-commentary and praise (delete)

"One result forced us to sharpen what 'survives' means, and it is the paper's
most transferable finding." (dst); "The important result does not require that
attribution" (cxlssd); "The contrast completes the intervention argument."
(cxlssd); "Size is the first thing a practitioner reaches for, and it is a weak
predictor." became "Graph size is a weak predictor." (cxlssd); "the paper's own
line"; "we do not hide" (tierce rebuttal rule: no defensive phrases); "smart
prefetching" (cxlssd blueprint: vague praise). The allochar review prompt ends
"No praise."

## 8. Supplementary: standard LLM tells (never observed in these papers; excluded on the user's request)

Words: delve, leverage, utilize, facilitate, enable (as a reflex; epic cut
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
