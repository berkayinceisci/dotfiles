# Transformation bank

Exact before/after pairs from the polish commits, grouped by the rule they
illustrate. Source is repository and commit hash. LaTeX is left as it appeared.
Use these as calibration: when unsure whether a sentence needs work, find the
nearest row.

## Metaphor to literal

| before | after | source |
|-|-|-|
| \noindent\textbf{Merging is a lever the system has already pulled.} Every deficit in this paper is measured net of a subsidy. | \noindent\textbf{Merging's contribution is already in every measurement.} Block-layer merging is enabled by default, so every bandwidth number in this paper already includes its effect. | paper C  |
| mq-deadline silently converts waiting depth into request size. | mq-deadline coalesces them, so queued depth that cannot become device occupancy becomes request size instead. | paper C  |
| Fig. prices the subsidy by turning it off. | Fig. measures the contribution directly by disabling merging (\ts{nomerges=2}) | paper C  |
| it is not uniformly a gift: | the effect is not uniformly positive: | paper C  |
| a single temperature class buys a single destination---one | hint---one | paper C  |
| The device is not slower on the fabric. It is emptier. | deleted | paper C  |
| the wall | the throughput limit / the delivery limit | paper C  |
| The extra contexts are not free. | Additional contexts incur overhead. | paper C |
| The remedy therefore has a crossover, not a universally positive return. | The benefit therefore depends on request size. | paper C |
| genuinely occupancy-starved | occupancy-limited | paper C |
| Device truth is read at the target | Device-side measurements are read at the target | paper C |
| An allocator's defaults are bets about the program it will serve, and what a bet leaves behind is memory state | Allocator defaults encode workload assumptions that persist as memory state | paper A |
| the accounts by meter: a failed bet charges a rate of events times a price per event on one of three meters | Each of the three costs is a count of events, calls, pages, or accesses, times what one event costs | paper A |
| different currencies that optimizations move independently | distinct quantities that a host optimization moves independently | paper B  |
| One load thus participates in three different currencies: | One load thus incurs three separable costs: | paper B  |
| Read each row as a purchase: / halves the BG's bill / is not a bargain; | trade: / cost / is not a saving; | paper E,  |
| The BG has to want the ways back. | The BG must benefit from returned ways. | paper E  |
| produces the visually appealing sawtooth | reallocates constantly | paper E |
| \textbf{dynprobe} trusts no passive signal: it periodically takes one way away and keeps the release only if the FG's throughput tolerated it. | \textbf{dynprobe} periodically removes one way and retains the release only when FG throughput remains stable. | paper E  |
| The redistribution itself turns out to be immaterial: | In practice even that shift does not matter: | paper E  |
| The \mycc compiler bridges high-level \mydsl functions and efficient execution on | The \mycc compiler lowers \mydsl functions into efficient, multi-target binaries for | paper D  |
| per-gap, per-component patchwork | per-gap, single-layer solutions | paper D  |
| beyond the reach of prior ISC frameworks | that prior ISC frameworks cannot express | paper D  |
| CXL-SSDs expose flash capacity through ordinary loads and stores | CXL-SSDs expand memory capacity with flash | paper B |
| an approach that is tedious and error-prone. | The barrier limits not only development productivity but also achievable performance. | paper D  |

## Slogans, headings, caption titles, run-in leads

| before | after | source |
|-|-|-|
| \section{Request Timing: Benefit Above, Cost Below} | \section{Changing When a Request Is Issued} | paper B  |
| \section{Charge the Execution That Pays} | \section{Accounting for the Whole Execution} | paper B  |
| \subsection{The Access Path} | \subsection{From a CPU Load to an SSD Access} | paper B |
| \section{Three Ways a Write Path Fails} | \section{Occupancy, Delivery, and Dependency Limits} | paper C |
| One load, three costs. (conclusion opener) | the claim itself with its numbers | paper B  |
| Same policy, same direction, opposite signs. | deleted | paper A |
| \noindent\textbf{Yet ordinary Linux workloads lose anyway.} | \noindent\textbf{Software limits on remote writes.} | paper C |
| \noindent\textbf{Blind spots define the method.} | \noindent\textbf{Scope.} | paper C |
| \noindent\textbf{Real workloads remain the harder test.} | \noindent\textbf{Workload validation.} | paper C |
| The Same Device Costs Different Programs Very Differently | Per-program cost of one device | paper B  |
| Size does not predict the penalty | Footprint against penalty | paper B  |
| Disabling late lookahead keeps the early gain | Effect of gating late lookahead | paper B  |
| \mycaption{fig-qd1-lat}{One write, three paths} | {QD1 write latency by access path} | paper C  |
| {What merging was quietly contributing.} | {Effect of request merging on write bandwidth.} | paper C |
| {Three failures, three remedies.} | {Write-path limits and corresponding interventions.} | paper C |
| Where the crowd thins}{The shape of every diagnosis here. | {Schematic. The shape of an occupancy-limited path. | paper C |
| \para{1:1 ratio.} | \para{Placement quality, not sampling rate, separates the systems.} | paper E  |
| Does dCAT beat a well-chosen sCAT split on top of live \sys? | deleted | paper E |
| The key question is: \emph{which microarchitectural signals predict FG slowdown under multi-tenant tiering, and which of them can support an online OS policy?} | We ask which microarchitectural signals predict this slowdown and which can drive an online OS policy. | paper E  |
| One objection is worth answering here, because the rest of the paper depends on the answer: no operator recovers performance by turning up an application's queue depth. True, and on a zoned drive nobody needs to. | Application writers can already supply enough work while zone placement restricts device occupancy. | paper C |
| Takeaway: ... brings huge performance benefits (box) | deleted | paper D  |

## Scaffolding, roadmaps, restating topic sentences, meta-commentary

| before | after | source |
|-|-|-|
| Two responses follow. | deleted | paper A |
| The model is the set index. | deleted | paper A |
| The one-change arm is the interval. | deleted | paper A |
| cppcheck carries the allocator-side arm. | deleted | paper A |
| GAPBS is the control where the bet holds: every allocator | Every allocator | paper A |
| Three terms recur in the survey statistics. An item is | An item is | paper A |
| Section~\ref{sec:des} develops these four components. | deleted | paper E |
| However, the sweep yields two critical insights. | Two results from the sweep guide the policy. | paper E  |
| without changing the skeleton, making it flexible to support different LLC allocation policies. | without changing the skeleton. | paper E  |
| Crucially, Figure~\ref{fig-ldlat-cdf} shows that remote-memory accesses separate cleanly | Remote-memory accesses separate cleanly | paper E |
| The exception is informative. | deleted | paper B  |
| It can. | deleted | paper B  |
| They establish the result that matters here without either attribution. | deleted | paper B  |
| That is why the rest of this section measures where a request is actually served. | deleted | paper B  |
| The contrast completes the intervention argument. | deleted | paper B |
| These controls answer different design questions. | deleted | paper B |
| The important result does not require that attribution: | Regardless of that attribution, | paper B |
| A separate activation control explains an earlier negative result of this kind: | An activation control isolates eligibility as a precondition for that movement. | paper B  |
| Size is the first thing a practitioner reaches for, and it is a weak predictor. | Graph size is a weak predictor. | paper B |
| This is Little's law, and we claim no novelty for it. Our observation is about the other quantity | deleted | paper C |
| One result forced us to sharpen what ``survives'' means, and it is the paper's most transferable finding. | deleted | paper C |
| Its pipeline consists of three stages: ... Each stage progressively reduces the semantic gap | deleted | paper D  |
| Together, these techniques allow \mycc to generate efficient multi-binary implementations that fully exploit the diverse capabilities of modern CSDs. | deleted | paper D  |
| Together, these results demonstrate that heterogeneous mapping and compiler-driven kernel fusion are essential to unlocking the full performance | deleted | paper D  |
| After compilation, \sys performs a series of coordinated steps to set up and launch offloading, as illustrated in \autoref{fig:rt}. The compiler produces | As illustrated in \autoref{fig:rt}, the compiler produces | paper D  |
| The trade-offs above can be understood through a simple throughput model. | A roofline model explains these trade-offs. | paper D  |
| But the substrate differs fundamentally: those compilers | But those compilers | paper D |
| Evaluating a full-stack ISC system requires both end-to-end system fidelity and component-level cycle accuracy. Pure emulation cannot ... | The complete host, NVMe, FTL, flash, and firmware path runs in FEMU | paper D  |
| Our evaluation aims to answer the following questions: \item | Our evaluation asks four questions: whether | paper D  |
| \sys reconstructs PAC from workload-isolated observations and bounded LLC residency control. (caption) | Pipeline differences beneath \pac{}. | paper E  |

## Negative parallelism and defensive negation

| before | after | source |
|-|-|-|
| We claim observed mechanisms on these hosts, not a predictor: no held-out prediction test was run. | We claim observed mechanisms on these hosts; no held-out prediction test was run, so nothing here is a predictor. | paper A |
| This is measured attenuation, not immunity: | This is measured attenuation when ... itself; it does not establish immunity, because | paper A |
| a second outcome, not a trade | a second outcome, and no automatic trade | paper A |
| What removing walks is worth is a fit, not a prediction. Over 140 Redis cells | What removing walks is worth is a fit over 140 Redis cells | paper A |
| The cliffs come from longer allocator paths rather than from misses | ... paths, not from misses | paper A |
| tcmalloc refers to this allocator rather than gperftools | tcmalloc means this allocator, not gperftools | paper A |
| A policy can also shift cost between channels rather than changing only one of them. | A policy can also move cost between channels. | paper A |
| the gap is a witness, not an oracle, and it does not say which policy or why | the gap witnesses that fact without naming the policy behind it | paper A |
| What is new is the combination | Our contribution is the combination | paper A |
| so its lower BG cost comes from sacrificing FG protection, not from a better allocation. | so its lower BG cost comes from sacrificing FG protection. | paper E |
| use established host-side techniques as \emph{probes} of different boundaries rather than propose a new prefetcher | use established host-side techniques to perturb different boundaries; we propose no new prefetcher | paper B |
| The gate is a follow-up probe, not a derived policy | The gate is a follow-up experiment, not a derived policy | paper B |
| What none of this prior work does is measure one host change at all three boundaries at once | None of the work above reports one host change at the CPU, link, and controller boundaries together | paper B |
| Nor is it simply insufficient queue depth. | The limit is not insufficient queue depth. | paper C  |
| 644 is the trigger-absent control. | 644 separates alignment from page return. | paper A |

## Intensifiers, hedges, filler

| before | after | source |
|-|-|-|
| The central challenge is therefore | The challenge is therefore | paper E  |
| is explicitly tier-dependent. At a 15/5 way split | is tier-dependent: at a 15/5 split | paper E (the colon predates rule 11, which would end the sentence instead) |
| compared to just 6.1\% on local DRAM. Preventing an eviction is vastly more valuable when | but 6.1\% on local DRAM, because preventing an eviction matters more when | paper E |
| allowing its criticality signals to accurately price the misses | so its criticality signals price the misses | paper E |
| Way allocation is especially important under tiered memory, because | Way allocation matters under tiered memory because | paper E  |
| sufficiently cache-elastic to exploit released ways | able to exploit released ways | paper E |
| That number is misleading, though. | That number is misleading. | paper E |
| It is especially effective for fs\_mark | It suits fs\_mark | paper C  |
| averages about seventeen and, more importantly, reaches zero | averages about seventeen and reaches zero | paper C  |
| More application threads do not simply turn | do not turn | paper C |
| can nevertheless lose throughput | can lose throughput | paper C |
| essentially the same recovery obtained by | comparable to the | paper C |
| a mechanism that never reverses anywhere in the suite | a mechanism that never reverses in our suite | paper A |
| More strikingly, across three independent blocks, | deleted | paper B |
| can also be easily extended to alternative scheduling policies | can be extended to priority-based or QoS-aware policies. | paper D  |
| To connect the host and device seamlessly, | To unify I/O handling with computation scheduling, | paper D  |
| \sys therefore avoids ... synchronization by design. | \sys needs no ... synchronization. | paper D |
| We can observe that Host has stable saturated PCIe bandwidth and frequently stalled computation. | Host has saturated PCIe bandwidth and frequent compute stalls. | paper D  |

## Connectives and sentence joins

| before | after | source |
|-|-|-|
| Page placement helps only when a workload has tiering headroom. On \ts{sssp-kron}, every evaluated tiering policy trails | Page placement needs tiering headroom: \ts{sssp-kron} trails | paper E  |
| Since \ts{cc-urand} runs fastest without LLC partitioning, our ... | \ts{cc-urand} is fastest unpartitioned, so our ... | paper E |
| Because each covers only one stage of the request lifetime, tiered-memory systems must | Each covers only one stage of the request lifetime, so tiered-memory systems must | paper E  |
| While CAT is a standard partitioning actuator, its necessity | CAT is a standard actuator, but its necessity | paper E  |
| ($r=-0.71$ to $-0.92$). Thus, pooled MLP reflects | ($r=-0.71$ to $-0.92$), so pooled MLP reflects | paper E |
| Consequently, page migration alone cannot distinguish whether | Migration alone therefore cannot tell whether | paper E |
| Under colocation, however, these observations become interleaved across workloads (...), making PAC no longer directly observable. | Under colocation those observations interleave across workloads (...), and PAC is no longer directly observable. | paper E |
| L2Lat interprets average L2-miss latency, which is ambiguous because low latency can indicate either | L2Lat reads average L2-miss latency, which is ambiguous: low latency can mean | paper E  |
| matches the full policy (\sec...)---the mechanism's gain comes from | matches the full policy (\sec...), so the gain comes from | paper E |
| \ts{fsync} can block---this page wait and the jbd2 commit wait---together account | can block, this page wait and the jbd2 commit wait, together account | paper C  |
| Here, ``memory-bound'' means | ``memory-bound'' means | paper E  |
| requires programming filters on every CHA slice, while two counters are needed to derive its MLP. Since the available uncore counters cannot simultaneously cover all managed core--tier pairs, | requires filters on every CHA slice, and two counters to derive its MLP, so the available counters cannot cover all managed pairs at once. | paper E  |
| Depending on input residency, the same computation may require different storage accesses and data transfers. Explicit location types make these requirements available for ahead-of-time compilation. | Since input residency affects storage accesses and data transfers, explicit location types let \sys plan these operations ahead of time. | paper D  |
| Host outperforms CSD-Seq and CSD-Pf due to the higher core speed and sufficient PCIe bandwidth. As core count increases, CSD-Seq and CSD-Pf surpass Host, while CSD-Nfp achieves the highest speed in most cases. | Host leads at low core counts but is overtaken by CSD-Seq and CSD-Pf as cores increase, while CSD-Nfp is fastest in most configurations. | paper D  |
| In the repeated arms (n=3) both gain the same 0.02 s per trial while removing different system calls | The repeated arms (n=3) gain the same 0.02 s per trial even though they remove different | paper A |
| A mechanism that is present is not always worth fixing: on pr-kron | Presence alone does not make a mechanism worth changing. On pr-kron | paper A |

## Verbs, agents, nominalizations, passive

| before | after | source |
|-|-|-|
| The state left behind is the cache's contents, and the payer is the allocator's own call path: | The allocator call path then pays for the cache contents through | paper A |
| the allocation call that happens to fire the walk, together with every request queued behind it | the allocation call that fires the walk pays it, along with every request queued behind that call | paper A |
| The walk is most of that loss | The heap walk accounts for most of the loss | paper A |
| sys takes 17.6 M minor faults | sys incurs 17.6 M minor faults | paper A |
| disabling jemalloc's decay takes elapsed time from 15.2 to 2.70 s | disabling jemalloc's decay cuts elapsed time from | paper A |
| the pool has no per-class reservation: | The shared pool reserves no bytes per class: | paper A |
| This affine model allows an operator to size | An operator can therefore size | paper E |
| Low L2 latency is misread as permission to release | It misreads low L2 latency as permission to release | paper E  |
| Intel CAT controls LLC residency by partitioning cache capacity | Intel CAT partitions cache capacity | paper E  |
| only if FG throughput remains stable. | only if FG throughput holds. | paper E |
| Repeated use must repay these preparation costs. | Reordering should save more runtime than it takes. | paper B |
| How much progress the CPU can sustain depends on | How quickly the CPU can retire instructions depends on | paper B |
| can help the CPU make progress | can reduce the time the CPU spends waiting for data | paper B |
| and both must be measured | and each has to be measured | paper B |
| \item A systematic characterization of CXL-SSD performance | \item We systematically characterize CXL-SSD performance | paper B |
| This paper makes three contributions: | We make three contributions: | paper B |
| remain allocated until explicit host release. | until the host explicitly releases them. | paper D  |
| the LoC value is measured from a rewrite of the same workload | we rewrite the same workload ... and count its application-side lines of code. | paper D  |
| \myrt is integrated directly into FEMU firmware execution threads. | \myrt runs in FEMU firmware execution threads | paper D  |
| \sys enables end-to-end optimization of in-storage workflows | \sys optimizes in-storage workflows end to end | paper D  |
| developers invoke it via paper D.accel(...), provide a code emitter in \mycc to lower the call, and register a dispatcher in \myrt. | a paper D.accel("xpu", params) call in \mydsl, a code emitter in \mycc, and a dispatcher in \myrt. | paper D  |
| The count-selected configuration finishes 15.2--16.1\% sooner in every block using | Count selection is 15.2--16.1\% faster in every block with | paper B |
| so policy activation and between-run device state are not fully separated | leaving policy activation and between-run device state confounded | paper B |
| the counter a practitioner would reach for first | the event a practitioner reaches for first | paper B |

## Lab vocabulary to reader vocabulary

| before | after | source |
|-|-|-|
| one process per arm | one process per configuration | paper B  |
| the hints-off arm | the hints-off control | paper B  |
| hints-off and hints-on arms | hints-off and hints-on builds | paper B  |
| Separate matched campaign: | Separate matched experiment: | paper B  |
| three-arm | three-way | paper B |
| Lookahead reads the identifier some edges ahead and requests the value early. | The lookahead reads the identifier of a neighbor several edges further along the list and requests that neighbor's value before the loop reaches it. | project F |
| so elapsed time alone does not fully describe a policy's cost. | so traversal time alone does not show what a policy costs. | project F |
| The policy must create enough lead time to hide waiting | The policy must issue each request early enough that the data arrive before the program needs them | project F |
| The lead time a hardware prefetcher can create is bounded by what it sees in the address stream; the backend latency is not. | A hardware prefetcher ... runs only a few accesses ahead of the program, so its request goes out a few hundred nanoseconds before the data are needed. That head start hides much of a cached line's 840 ns but almost none of a 15 to 30 us flash fill | project F (its "15 to 30 us" predates the range rule, which writes 15--30 us) |
| eight workers | eight threads | paper B |
| intervention | optimization | paper B  |
| Channel A / Channel B / Channel C | allocator execution / kernel memory management / application memory access | paper A |
| cell | allocator--workload combination | paper A |
| matches local at $\sim$2.9\,GB/s | matches local at 2.9\,GB/s | paper C  |
| holds full-rate-class hot-set residency | reaches nearly the same hot-set residency | paper E  |
| every measured second contains churn. | the cell measures only the convergence transient. | paper E  |
| L1Lat/L2Lat/L3Lat are miss latencies; L3MLP is LLC-miss MLP (caption) | L1Lat/L2Lat/L3Lat: miss latencies; L3MLP: LLC-miss MLP | paper E  |
| Top-down accounting assigns pipeline slots to retirement, speculation, frontend, and backend categories. | Top-down analysis classifies pipeline slots, or opportunities to process instructions, by useful retirement, speculation, and frontend or backend limits. | paper B |
| A hit returns the requested 64\,B line. A miss fetches a 4\,KiB block from the backend, installs it in DRAM | A hit supplies the requested 64\,B cache line. A miss reads a 4\,KiB block from the SSD, installs it in the device cache | paper B |
| does not guarantee identical numerical progress. | does not guarantee that PageRank produces equally accurate scores. | paper B |
| sequential consistency guarantees provided by the runtime | invocation-order consistency enforced by the runtime | paper D  |
| "(e.g.," | "(\eg," | paper D  |

## Numbers

| before | after | source |
|-|-|-|
| 0.0000152 under tc | essentially zero under tc | paper A |
| together 0.012\% of allocations | about one allocation in 8,000 | paper A |
| Most application configurations have several competitive allocator choices, but some suffer large losses. | Allocator choice often leaves several competitive options: 372 of 382 application points have at least two allocators within 5\% | paper A |
| je holds 98\% on 644 | je's coverage at peak anonymous memory on 644 is 98\% | paper A |
| reading half again as much from flash | reading 47.5--49.8\% more from flash | paper B  |
| An intervention can remove 92.1\% of demand misses and leave 95.9\% of link traffic | Gather lookahead removes 92.1\% of PageRank's demand misses and leaves 95.9\% of its link traffic. | paper B |
| the graph read is served 94.6\% from the backend | the graph read's NAND-read bytes are 94.6\% of its CXL-read bytes | paper B |
| A quarter run within 8\% of DRAM time | A quarter of the runs take at most 8\% longer than on local DRAM | paper B |
| merging \emph{costs} bandwidth ($-$9\% RDMA, $-$24\% TCP) | disabling it \emph{raises} bandwidth by 10\% on RDMA and 31\% on TCP | paper C  |
| holds fourteen times less at the device | holds one-fourteenth as much | paper C |
| lands anywhere from 4.3\,ms to 340\,ms p99 across trials, while | spans 4.3--340\,ms p99 across trials; | paper E |
| Medians of three runs. / three-run means (per caption) | Medians. / means, with one Method sentence on repetition | paper E  |
| Each point is one colocation experiment. $r = +0.91$ (local) and $r = +0.96$ (remote). | Each point represents one colocation experiment, grouped by memory placement. | paper E  |
| all systems degrade, but \wmlp degrades gracefully. On bc\_urand, \wmlp drops from 0.86 to 0.83 while NBT drops from 0.65 to 0.60 and PACT from 0.68 to 0.68. | PACT sits at 68\% on \texttt{bc\_urand} at \emph{both} ratios, which signals the opposite problem: it never converted the larger 1:1 budget into performance in the first place. | paper E  |
| delivering 4.2x geometric-mean speedup and up to 16.1x; it is 1.6x faster in geometric mean than the strongest restricted prior-derived configuration per workload | speedups of 4.2x over host baselines and 1.6x over the strongest prior system, on average. | paper D  |
| (tens of microseconds per invocation) | (microseconds per invocation) | paper D  |
| 4\,GB | 4\,GiB | paper B |

## Claims bounded to evidence

| before | after | source |
|-|-|-|
| the measured 271\,\us consists of three fabric writes | is consistent with three fabric writes ... the raw trace behind this decomposition was not retained, so we treat it as an illustration | paper C  |
| tracing its assignments shows that this workload's data files are labeled warm | The observed behavior is consistent with ... We infer that placement from the device-side occupancy | paper C  |
| (the above, once the trace existed) | An eBPF trace of F2FS's write-hint assignments confirms it | paper C  |
| the latency-bound workloads are explained without them | can be explained without them | paper C  |
| fs\_mark creates a file, writes 4\,KB, and \ts{fsync}s it, repeatedly | fs\_mark repeatedly creates a new file, writes 4\,KB, \ts{fsync}s it, and closes it---every iteration touches a fresh file | paper C  |
| the first ISC system to unify | an ISC system that unifies | paper D  |
| Host runtime increases with cores because aggregate PCIe demand grows | deleted (unverified causal claim) | paper D  |
| 12-line write-intensive limitation ("These are well understood: small updates can be buffered...") | Write-intensive workloads would benefit from write buffering and coalescing, both planned extensions. | paper D  |
| Our key insight is that a workload property determines whether a policy's cost ... outweighs its benefit. | A policy's cost is charged in one of three domains: per call, per page, or per access. | paper A |
| In this paper, we present a differential cross-layer approach to causal diagnosis | We present a cross-layer method for causal diagnosis: | paper A |
| Returning freed pages ... is normally understood as a trade: give back memory, pay a little time. | Memory allocation is part of the datacenter tax ... 22 to 27\% of fleet cycles | paper A |
| The writeback probes expose that residual dependency. | Page turnover explains the dependence on value size. Appends share a 4\,KB page until it fills; | paper C  |
| \item \textbf{A phenomenon.} Disaggregation exposes latent serialization | \item We show that disaggregation exposes ... (later: a characterization of occupancy, delivery, and dependency limits) | paper C  |
