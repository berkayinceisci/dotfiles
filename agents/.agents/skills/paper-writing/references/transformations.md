# Transformation bank

Exact before/after pairs from the polish commits, grouped by the rule they
illustrate. Source is repository and commit hash. LaTeX is left as it appeared.
Use these as calibration: when unsure whether a sentence needs work, find the
nearest row.

## Metaphor to literal

| before | after | source |
|-|-|-|
| \noindent\textbf{Merging is a lever the system has already pulled.} Every deficit in this paper is measured net of a subsidy. | \noindent\textbf{Merging's contribution is already in every measurement.} Block-layer merging is enabled by default, so every bandwidth number in this paper already includes its effect. | dst 8b37c39 |
| mq-deadline silently converts waiting depth into request size. | mq-deadline coalesces them, so queued depth that cannot become device occupancy becomes request size instead. | dst 8b37c39 |
| Fig. prices the subsidy by turning it off. | Fig. measures the contribution directly by disabling merging (\ts{nomerges=2}) | dst 8b37c39 |
| it is not uniformly a gift: | the effect is not uniformly positive: | dst 8b37c39 |
| a single temperature class buys a single destination---one | hint---one | dst 831fb90 |
| The device is not slower on the fabric. It is emptier. | deleted | dst aea4312 |
| the wall | the throughput limit / the delivery limit | dst aea4312 |
| The extra contexts are not free. | Additional contexts incur overhead. | dst |
| The remedy therefore has a crossover, not a universally positive return. | The benefit therefore depends on request size. | dst |
| genuinely occupancy-starved | occupancy-limited | dst |
| Device truth is read at the target | Device-side measurements are read at the target | dst |
| An allocator's defaults are bets about the program it will serve, and what a bet leaves behind is memory state | Allocator defaults encode workload assumptions that persist as memory state | allochar f14a958 |
| the accounts by meter: a failed bet charges a rate of events times a price per event on one of three meters | Each of the three costs is a count of events, calls, pages, or accesses, times what one event costs | allochar 7a405a0 |
| different currencies that optimizations move independently | distinct quantities that a host optimization moves independently | cxlssd 0e5f15c |
| One load thus participates in three different currencies: | One load thus incurs three separable costs: | cxlssd 0e5f15c |
| Read each row as a purchase: / halves the BG's bill / is not a bargain; | trade: / cost / is not a saving; | tierce f0ef62e, dde0fd9 |
| The BG has to want the ways back. | The BG must benefit from returned ways. | tierce dde0fd9 |
| produces the visually appealing sawtooth | reallocates constantly | tierce |
| \textbf{dynprobe} trusts no passive signal: it periodically takes one way away and keeps the release only if the FG's throughput tolerated it. | \textbf{dynprobe} periodically removes one way and retains the release only when FG throughput remains stable. | tierce 1c5406c |
| The redistribution itself turns out to be immaterial: | In practice even that shift does not matter: | tierce 1c5406c |
| The \mycc compiler bridges high-level \mydsl functions and efficient execution on | The \mycc compiler lowers \mydsl functions into efficient, multi-target binaries for | epic 7c30ecd |
| per-gap, per-component patchwork | per-gap, single-layer solutions | epic 7c30ecd |
| beyond the reach of prior ISC frameworks | that prior ISC frameworks cannot express | epic 20d9195 |
| CXL-SSDs expose flash capacity through ordinary loads and stores | CXL-SSDs expand memory capacity with flash | cxlssd |
| an approach that is tedious and error-prone. | The barrier limits not only development productivity but also achievable performance. | epic b80d592 |

## Slogans, headings, caption titles, run-in leads

| before | after | source |
|-|-|-|
| \section{Request Timing: Benefit Above, Cost Below} | \section{Changing When a Request Is Issued} | cxlssd 6ad4b77 |
| \section{Charge the Execution That Pays} | \section{Accounting for the Whole Execution} | cxlssd 6ad4b77 |
| \subsection{The Access Path} | \subsection{From a CPU Load to an SSD Access} | cxlssd |
| \section{Three Ways a Write Path Fails} | \section{Occupancy, Delivery, and Dependency Limits} | dst |
| One load, three costs. (conclusion opener) | the claim itself with its numbers | cxlssd 0e5f15c |
| Same policy, same direction, opposite signs. | deleted | allochar 20ffc62 |
| \noindent\textbf{Yet ordinary Linux workloads lose anyway.} | \noindent\textbf{Software limits on remote writes.} | dst |
| \noindent\textbf{Blind spots define the method.} | \noindent\textbf{Scope.} | dst |
| \noindent\textbf{Real workloads remain the harder test.} | \noindent\textbf{Workload validation.} | dst |
| The Same Device Costs Different Programs Very Differently | Per-program cost of one device | cxlssd dda7ade |
| Size does not predict the penalty | Footprint against penalty | cxlssd dda7ade |
| Disabling late lookahead keeps the early gain | Effect of gating late lookahead | cxlssd dda7ade |
| \mycaption{fig-qd1-lat}{One write, three paths} | {QD1 write latency by access path} | dst 487ff47 |
| {What merging was quietly contributing.} | {Effect of request merging on write bandwidth.} | dst |
| {Three failures, three remedies.} | {Write-path limits and corresponding interventions.} | dst |
| Where the crowd thins}{The shape of every diagnosis here. | {Schematic. The shape of an occupancy-limited path. | dst |
| \para{1:1 ratio.} | \para{Placement quality, not sampling rate, separates the systems.} | tierce 9340bcb |
| Does dCAT beat a well-chosen sCAT split on top of live \sys? | deleted | tierce |
| The key question is: \emph{which microarchitectural signals predict FG slowdown under multi-tenant tiering, and which of them can support an online OS policy?} | We ask which microarchitectural signals predict this slowdown and which can drive an online OS policy. | tierce ee4b591 |
| One objection is worth answering here, because the rest of the paper depends on the answer: no operator recovers performance by turning up an application's queue depth. True, and on a zoned drive nobody needs to. | Application writers can already supply enough work while zone placement restricts device occupancy. | dst |
| Takeaway: ... brings huge performance benefits (box) | deleted | epic ae8a36d |

## Scaffolding, roadmaps, restating topic sentences, meta-commentary

| before | after | source |
|-|-|-|
| Two responses follow. | deleted | allochar f14a958 |
| The model is the set index. | deleted | allochar f14a958 |
| The one-change arm is the interval. | deleted | allochar f14a958 |
| cppcheck carries the allocator-side arm. | deleted | allochar f14a958 |
| GAPBS is the control where the bet holds: every allocator | Every allocator | allochar f14a958 |
| Three terms recur in the survey statistics. An item is | An item is | allochar 67484c9 |
| Section~\ref{sec:des} develops these four components. | deleted | tierce |
| However, the sweep yields two critical insights. | Two results from the sweep guide the policy. | tierce f51c390 |
| without changing the skeleton, making it flexible to support different LLC allocation policies. | without changing the skeleton. | tierce f51c390 |
| Crucially, Figure~\ref{fig-ldlat-cdf} shows that remote-memory accesses separate cleanly | Remote-memory accesses separate cleanly | tierce |
| The exception is informative. | deleted | cxlssd 357af8c |
| It can. | deleted | cxlssd 357af8c |
| They establish the result that matters here without either attribution. | deleted | cxlssd 357af8c |
| That is why the rest of this section measures where a request is actually served. | deleted | cxlssd 357af8c |
| The contrast completes the intervention argument. | deleted | cxlssd |
| These controls answer different design questions. | deleted | cxlssd |
| The important result does not require that attribution: | Regardless of that attribution, | cxlssd |
| A separate activation control explains an earlier negative result of this kind: | An activation control isolates eligibility as a precondition for that movement. | cxlssd 357af8c |
| Size is the first thing a practitioner reaches for, and it is a weak predictor. | Graph size is a weak predictor. | cxlssd |
| This is Little's law, and we claim no novelty for it. Our observation is about the other quantity | deleted | dst |
| One result forced us to sharpen what ``survives'' means, and it is the paper's most transferable finding. | deleted | dst |
| Its pipeline consists of three stages: ... Each stage progressively reduces the semantic gap | deleted | epic 7c30ecd |
| Together, these techniques allow \mycc to generate efficient multi-binary implementations that fully exploit the diverse capabilities of modern CSDs. | deleted | epic 7c30ecd |
| Together, these results demonstrate that heterogeneous mapping and compiler-driven kernel fusion are essential to unlocking the full performance | deleted | epic 5bf784b |
| After compilation, \sys performs a series of coordinated steps to set up and launch offloading, as illustrated in \autoref{fig:rt}. The compiler produces | As illustrated in \autoref{fig:rt}, the compiler produces | epic 7196ba4 |
| The trade-offs above can be understood through a simple throughput model. | A roofline model explains these trade-offs. | epic ae8a36d |
| But the substrate differs fundamentally: those compilers | But those compilers | epic 4492797 |
| Evaluating a full-stack ISC system requires both end-to-end system fidelity and component-level cycle accuracy. Pure emulation cannot ... | The complete host, NVMe, FTL, flash, and firmware path runs in FEMU | epic 0b85bcb |
| Our evaluation aims to answer the following questions: \item | Our evaluation asks four questions: whether | epic ae0b7eb |
| \sys reconstructs PAC from workload-isolated observations and bounded LLC residency control. (caption) | Pipeline differences beneath \pac{}. | tierce 5d4c0d5 |

## Negative parallelism and defensive negation

| before | after | source |
|-|-|-|
| We claim observed mechanisms on these hosts, not a predictor: no held-out prediction test was run. | We claim observed mechanisms on these hosts; no held-out prediction test was run, so nothing here is a predictor. | allochar b420e09 |
| This is measured attenuation, not immunity: | This is measured attenuation when ... itself; it does not establish immunity, because | allochar b420e09 |
| a second outcome, not a trade | a second outcome, and no automatic trade | allochar b420e09 |
| What removing walks is worth is a fit, not a prediction. Over 140 Redis cells | What removing walks is worth is a fit over 140 Redis cells | allochar 44ca4fb |
| The cliffs come from longer allocator paths rather than from misses | ... paths, not from misses | allochar |
| tcmalloc refers to this allocator rather than gperftools | tcmalloc means this allocator, not gperftools | allochar 7970d34 |
| A policy can also shift cost between channels rather than changing only one of them. | A policy can also move cost between channels. | allochar |
| the gap is a witness, not an oracle, and it does not say which policy or why | the gap witnesses that fact without naming the policy behind it | allochar |
| What is new is the combination | Our contribution is the combination | allochar f14a958 |
| so its lower BG cost comes from sacrificing FG protection, not from a better allocation. | so its lower BG cost comes from sacrificing FG protection. | tierce |
| use established host-side techniques as \emph{probes} of different boundaries rather than propose a new prefetcher | use established host-side techniques to perturb different boundaries; we propose no new prefetcher | cxlssd |
| The gate is a follow-up probe, not a derived policy | The gate is a follow-up experiment, not a derived policy | cxlssd |
| What none of this prior work does is measure one host change at all three boundaries at once | None of the work above reports one host change at the CPU, link, and controller boundaries together | cxlssd |
| Nor is it simply insufficient queue depth. | The limit is not insufficient queue depth. | dst ac697fd |
| 644 is the trigger-absent control. | 644 separates alignment from page return. | allochar |

## Intensifiers, hedges, filler

| before | after | source |
|-|-|-|
| The central challenge is therefore | The challenge is therefore | tierce bb57da3 |
| is explicitly tier-dependent. At a 15/5 way split | is tier-dependent: at a 15/5 split | tierce 0136708 |
| compared to just 6.1\% on local DRAM. Preventing an eviction is vastly more valuable when | but 6.1\% on local DRAM, because preventing an eviction matters more when | tierce |
| allowing its criticality signals to accurately price the misses | so its criticality signals price the misses | tierce |
| Way allocation is especially important under tiered memory, because | Way allocation matters under tiered memory because | tierce 93d4b4a |
| sufficiently cache-elastic to exploit released ways | able to exploit released ways | tierce |
| That number is misleading, though. | That number is misleading. | tierce |
| It is especially effective for fs\_mark | It suits fs\_mark | dst 12971f0 |
| averages about seventeen and, more importantly, reaches zero | averages about seventeen and reaches zero | dst dc22372 |
| More application threads do not simply turn | do not turn | dst |
| can nevertheless lose throughput | can lose throughput | dst |
| essentially the same recovery obtained by | comparable to the | dst |
| a mechanism that never reverses anywhere in the suite | a mechanism that never reverses in our suite | allochar |
| More strikingly, across three independent blocks, | deleted | cxlssd |
| can also be easily extended to alternative scheduling policies | can be extended to priority-based or QoS-aware policies. | epic 7196ba4 |
| To connect the host and device seamlessly, | To unify I/O handling with computation scheduling, | epic 7196ba4 |
| \sys therefore avoids ... synchronization by design. | \sys needs no ... synchronization. | epic 4492797 |
| We can observe that Host has stable saturated PCIe bandwidth and frequently stalled computation. | Host has saturated PCIe bandwidth and frequent compute stalls. | epic ae8a36d |

## Connectives and sentence joins

| before | after | source |
|-|-|-|
| Page placement helps only when a workload has tiering headroom. On \ts{sssp-kron}, every evaluated tiering policy trails | Page placement needs tiering headroom: \ts{sssp-kron} trails | tierce 6cf3145 |
| Since \ts{cc-urand} runs fastest without LLC partitioning, our ... | \ts{cc-urand} is fastest unpartitioned, so our ... | tierce |
| Because each covers only one stage of the request lifetime, tiered-memory systems must | Each covers only one stage of the request lifetime, so tiered-memory systems must | tierce 720c104 |
| While CAT is a standard partitioning actuator, its necessity | CAT is a standard actuator, but its necessity | tierce 40757d7 |
| ($r=-0.71$ to $-0.92$). Thus, pooled MLP reflects | ($r=-0.71$ to $-0.92$), so pooled MLP reflects | tierce |
| Consequently, page migration alone cannot distinguish whether | Migration alone therefore cannot tell whether | tierce |
| Under colocation, however, these observations become interleaved across workloads (...), making PAC no longer directly observable. | Under colocation those observations interleave across workloads (...), and PAC is no longer directly observable. | tierce |
| L2Lat interprets average L2-miss latency, which is ambiguous because low latency can indicate either | L2Lat reads average L2-miss latency, which is ambiguous: low latency can mean | tierce 6d023b0 |
| matches the full policy (\sec...)---the mechanism's gain comes from | matches the full policy (\sec...), so the gain comes from | tierce |
| \ts{fsync} can block---this page wait and the jbd2 commit wait---together account | can block, this page wait and the jbd2 commit wait, together account | dst 9acca11 |
| Here, ``memory-bound'' means | ``memory-bound'' means | tierce d59f482 |
| requires programming filters on every CHA slice, while two counters are needed to derive its MLP. Since the available uncore counters cannot simultaneously cover all managed core--tier pairs, | requires filters on every CHA slice, and two counters to derive its MLP, so the available counters cannot cover all managed pairs at once. | tierce 396e984 |
| Depending on input residency, the same computation may require different storage accesses and data transfers. Explicit location types make these requirements available for ahead-of-time compilation. | Since input residency affects storage accesses and data transfers, explicit location types let \sys plan these operations ahead of time. | epic bdb3962 |
| Host outperforms CSD-Seq and CSD-Pf due to the higher core speed and sufficient PCIe bandwidth. As core count increases, CSD-Seq and CSD-Pf surpass Host, while CSD-Nfp achieves the highest speed in most cases. | Host leads at low core counts but is overtaken by CSD-Seq and CSD-Pf as cores increase, while CSD-Nfp is fastest in most configurations. | epic ae8a36d |
| In the repeated arms (n=3) both gain the same 0.02 s per trial while removing different system calls | The repeated arms (n=3) gain the same 0.02 s per trial even though they remove different | allochar |
| A mechanism that is present is not always worth fixing: on pr-kron | Presence alone does not make a mechanism worth changing. On pr-kron | allochar |

## Verbs, agents, nominalizations, passive

| before | after | source |
|-|-|-|
| The state left behind is the cache's contents, and the payer is the allocator's own call path: | The allocator call path then pays for the cache contents through | allochar f14a958 |
| the allocation call that happens to fire the walk, together with every request queued behind it | the allocation call that fires the walk pays it, along with every request queued behind that call | allochar f14a958 |
| The walk is most of that loss | The heap walk accounts for most of the loss | allochar |
| sys takes 17.6 M minor faults | sys incurs 17.6 M minor faults | allochar |
| disabling jemalloc's decay takes elapsed time from 15.2 to 2.70 s | disabling jemalloc's decay cuts elapsed time from | allochar |
| the pool has no per-class reservation: | The shared pool reserves no bytes per class: | allochar |
| This affine model allows an operator to size | An operator can therefore size | tierce |
| Low L2 latency is misread as permission to release | It misreads low L2 latency as permission to release | tierce 5a66b3e |
| Intel CAT controls LLC residency by partitioning cache capacity | Intel CAT partitions cache capacity | tierce 720c104 |
| only if FG throughput remains stable. | only if FG throughput holds. | tierce |
| Repeated use must repay these preparation costs. | Reordering should save more runtime than it takes. | cxlssd |
| How much progress the CPU can sustain depends on | How quickly the CPU can retire instructions depends on | cxlssd |
| can help the CPU make progress | can reduce the time the CPU spends waiting for data | cxlssd |
| and both must be measured | and each has to be measured | cxlssd |
| \item A systematic characterization of CXL-SSD performance | \item We systematically characterize CXL-SSD performance | cxlssd |
| This paper makes three contributions: | We make three contributions: | cxlssd |
| remain allocated until explicit host release. | until the host explicitly releases them. | epic 5b19ab7 |
| the LoC value is measured from a rewrite of the same workload | we rewrite the same workload ... and count its application-side lines of code. | epic 5b19ab7 |
| \myrt is integrated directly into FEMU firmware execution threads. | \myrt runs in FEMU firmware execution threads | epic 5b19ab7 |
| \sys enables end-to-end optimization of in-storage workflows | \sys optimizes in-storage workflows end to end | epic 5b19ab7 |
| developers invoke it via epic.accel(...), provide a code emitter in \mycc to lower the call, and register a dispatcher in \myrt. | a epic.accel("xpu", params) call in \mydsl, a code emitter in \mycc, and a dispatcher in \myrt. | epic fab46e7 |
| The count-selected configuration finishes 15.2--16.1\% sooner in every block using | Count selection is 15.2--16.1\% faster in every block with | cxlssd |
| so policy activation and between-run device state are not fully separated | leaving policy activation and between-run device state confounded | cxlssd |
| the counter a practitioner would reach for first | the event a practitioner reaches for first | cxlssd |

## Lab vocabulary to reader vocabulary

| before | after | source |
|-|-|-|
| one process per arm | one process per configuration | cxlssd b96b83c |
| the hints-off arm | the hints-off control | cxlssd b96b83c |
| hints-off and hints-on arms | hints-off and hints-on builds | cxlssd b96b83c |
| Separate matched campaign: | Separate matched experiment: | cxlssd b96b83c |
| three-arm | three-way | cxlssd |
| Lookahead reads the identifier some edges ahead and requests the value early. | The lookahead reads the identifier of a neighbor several edges further along the list and requests that neighbor's value before the loop reaches it. | agos-project 2026-11-01 |
| so elapsed time alone does not fully describe a policy's cost. | so traversal time alone does not show what a policy costs. | agos-project 2026-11-01 |
| The policy must create enough lead time to hide waiting | The policy must issue each request early enough that the data arrive before the program needs them | agos-project 2026-11-01 |
| The lead time a hardware prefetcher can create is bounded by what it sees in the address stream; the backend latency is not. | A hardware prefetcher ... runs only a few accesses ahead of the program, so its request goes out a few hundred nanoseconds before the data are needed. That head start hides much of a cached line's 840 ns but almost none of a 15 to 30 us flash fill | agos-project 2026-11-01 |
| eight workers | eight threads | cxlssd |
| intervention | optimization | cxlssd 73668df |
| Channel A / Channel B / Channel C | allocator execution / kernel memory management / application memory access | allochar 71c66a1 |
| cell | allocator--workload combination | allochar a04ffca |
| matches local at $\sim$2.9\,GB/s | matches local at 2.9\,GB/s | dst 94f2df9 |
| holds full-rate-class hot-set residency | reaches nearly the same hot-set residency | tierce 1c5406c |
| every measured second contains churn. | the cell measures only the convergence transient. | tierce 0ba1226 |
| L1Lat/L2Lat/L3Lat are miss latencies; L3MLP is LLC-miss MLP (caption) | L1Lat/L2Lat/L3Lat: miss latencies; L3MLP: LLC-miss MLP | tierce e01c978 |
| Top-down accounting assigns pipeline slots to retirement, speculation, frontend, and backend categories. | Top-down analysis classifies pipeline slots, or opportunities to process instructions, by useful retirement, speculation, and frontend or backend limits. | cxlssd |
| A hit returns the requested 64\,B line. A miss fetches a 4\,KiB block from the backend, installs it in DRAM | A hit supplies the requested 64\,B cache line. A miss reads a 4\,KiB block from the SSD, installs it in the device cache | cxlssd |
| does not guarantee identical numerical progress. | does not guarantee that PageRank produces equally accurate scores. | cxlssd |
| sequential consistency guarantees provided by the runtime | invocation-order consistency enforced by the runtime | epic 7c30ecd |
| "(e.g.," | "(\eg," | epic 7c30ecd |

## Numbers

| before | after | source |
|-|-|-|
| 0.0000152 under tc | essentially zero under tc | allochar 5b1a4e4 |
| together 0.012\% of allocations | about one allocation in 8,000 | allochar 5b1a4e4 |
| Most application configurations have several competitive allocator choices, but some suffer large losses. | Allocator choice often leaves several competitive options: 372 of 382 application points have at least two allocators within 5\% | allochar a04ffca |
| je holds 98\% on 644 | je's coverage at peak anonymous memory on 644 is 98\% | allochar 9163f47 |
| reading half again as much from flash | reading 47.5--49.8\% more from flash | cxlssd 0e5f15c |
| An intervention can remove 92.1\% of demand misses and leave 95.9\% of link traffic | Gather lookahead removes 92.1\% of PageRank's demand misses and leaves 95.9\% of its link traffic. | cxlssd |
| the graph read is served 94.6\% from the backend | the graph read's NAND-read bytes are 94.6\% of its CXL-read bytes | cxlssd |
| A quarter run within 8\% of DRAM time | A quarter of the runs take at most 8\% longer than on local DRAM | cxlssd |
| merging \emph{costs} bandwidth ($-$9\% RDMA, $-$24\% TCP) | disabling it \emph{raises} bandwidth by 10\% on RDMA and 31\% on TCP | dst 8b37c39 |
| holds fourteen times less at the device | holds one-fourteenth as much | dst |
| lands anywhere from 4.3\,ms to 340\,ms p99 across trials, while | spans 4.3--340\,ms p99 across trials; | tierce 1376167 |
| Medians of three runs. / three-run means (per caption) | Medians. / means, with one Method sentence on repetition | tierce 2a21b2c |
| Each point is one colocation experiment. $r = +0.91$ (local) and $r = +0.96$ (remote). | Each point represents one colocation experiment, grouped by memory placement. | tierce ce7fa23 |
| all systems degrade, but \wmlp degrades gracefully. On bc\_urand, \wmlp drops from 0.86 to 0.83 while NBT drops from 0.65 to 0.60 and PACT from 0.68 to 0.68. | PACT sits at 68\% on \texttt{bc\_urand} at \emph{both} ratios, which signals the opposite problem: it never converted the larger 1:1 budget into performance in the first place. | tierce 9340bcb |
| delivering 4.2x geometric-mean speedup and up to 16.1x; it is 1.6x faster in geometric mean than the strongest restricted prior-derived configuration per workload | speedups of 4.2x over host baselines and 1.6x over the strongest prior system, on average. | epic cd72df2 |
| (tens of microseconds per invocation) | (microseconds per invocation) | epic 247df86 |
| 4\,GB | 4\,GiB | cxlssd |

## Claims bounded to evidence

| before | after | source |
|-|-|-|
| the measured 271\,\us consists of three fabric writes | is consistent with three fabric writes ... the raw trace behind this decomposition was not retained, so we treat it as an illustration | dst c136a2e |
| tracing its assignments shows that this workload's data files are labeled warm | The observed behavior is consistent with ... We infer that placement from the device-side occupancy | dst c136a2e |
| (the above, once the trace existed) | An eBPF trace of F2FS's write-hint assignments confirms it | dst cae7b64 |
| the latency-bound workloads are explained without them | can be explained without them | dst f2530ac |
| fs\_mark creates a file, writes 4\,KB, and \ts{fsync}s it, repeatedly | fs\_mark repeatedly creates a new file, writes 4\,KB, \ts{fsync}s it, and closes it---every iteration touches a fresh file | dst cd984cf |
| the first ISC system to unify | an ISC system that unifies | epic 20d9195 |
| Host runtime increases with cores because aggregate PCIe demand grows | deleted (unverified causal claim) | epic 5bf784b |
| 12-line write-intensive limitation ("These are well understood: small updates can be buffered...") | Write-intensive workloads would benefit from write buffering and coalescing, both planned extensions. | epic e4b977c |
| Our key insight is that a workload property determines whether a policy's cost ... outweighs its benefit. | A policy's cost is charged in one of three domains: per call, per page, or per access. | allochar 075bd93 |
| In this paper, we present a differential cross-layer approach to causal diagnosis | We present a cross-layer method for causal diagnosis: | allochar a04ffca |
| Returning freed pages ... is normally understood as a trade: give back memory, pay a little time. | Memory allocation is part of the datacenter tax ... 22 to 27\% of fleet cycles | allochar 20ffc62 |
| The writeback probes expose that residual dependency. | Page turnover explains the dependence on value size. Appends share a 4\,KB page until it fills; | dst 970c6b4 |
| \item \textbf{A phenomenon.} Disaggregation exposes latent serialization | \item We show that disaggregation exposes ... (later: a characterization of occupancy, delivery, and dependency limits) | dst 6a3d82b |
