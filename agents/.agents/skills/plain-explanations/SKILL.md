---
name: plain-explanations
description: Explain technical concepts, code behavior, and tradeoffs in plain English while preserving detail and uncertainty. Use for substantive questions such as "how does this work" or "why does this happen", and requests to explain simply, remove jargon, or rewrite an explanation for clarity. Research-paper drafting and editing belong to paper-writing.
---

# Plain explanations

Help the reader understand the answer on the first read. Use STE-inspired
language, with enough detail to explain the mechanism. These are local writing
preferences, not a claim of ASD-STE100 compliance.

## Build the explanation

- Start with the answer or the observed result. Omit announcements of what you
  are about to explain.
- Introduce each fact before the reader needs it. For a mechanism, explain
  what starts the process, what each part does, and how that produces the result.
  Name the actor and the object of each important action.
- Use familiar words around necessary technical terms. Explain an unfamiliar
  term briefly at first use, then keep its name consistent. Match the explanation
  to the reader's demonstrated knowledge; do not repeatedly define familiar terms.
- Keep one main idea per sentence and one topic per paragraph. Split long
  sentences where doing so helps comprehension. Use words such as "because",
  "if", and "so" to preserve the connection between statements.
- Prefer concrete verbs to abstract noun phrases. Remove ceremonial openers,
  claims about importance, slogans, and summaries that repeat the answer.
  Avoid invented labels and long chains of nouns.
- Use one small example when the mechanism would otherwise stay abstract.
  Clearly label hypothetical inputs and outcomes. For questions about code,
  include the relevant source snippet and explain how it produces the behavior.
- Use enough space to answer the question. Do not impose a fixed sentence count,
  force every explanation into a template, or replace useful detail with brevity.

## Preserve meaning

- Keep facts, numbers, units, conditions, exceptions, and degrees of certainty.
  A rewrite must not add a cause, measurement, or outcome absent from its source.
  Separate observations from hypotheses and name what remains unknown.
- Keep "may", "might", "could", and "should" when they express uncertainty,
  possibility, or advice. Do not rewrite "should" as "must" unless the source
  establishes a requirement.
- Preserve code, identifiers, commands, paths, and quoted errors exactly when
  rewriting surrounding prose. Investigating or fixing them is a separate task.
- Choose words by meaning. Do not collapse distinct operations into one term
  just to enforce consistent vocabulary. For example, checking whether a file
  exists and verifying its contents are different operations.
- Prefer literal descriptions. Use an analogy only if it helps explain the
  actual mechanism, and state where the analogy stops applying.

## Choose the useful form

Use prose for a direct answer, a list for steps or parallel items, and a table
for comparison across shared attributes. Formatting must expose structure.
Do not add a heading or bold label to each sentence.

Use a visual when the reader would otherwise need to reconstruct a relationship:

- Sequence diagram: the order of messages or actions, and who performs them.
- Component diagram: what connects to what, with arrows labeled by what moves.
- State diagram: which events change the state and which transitions are allowed.
- Plot: how measured values or an explicitly stated model vary with an input.
- Interactive example: changing an input helps the reader test a prediction.

Prefer a small Mermaid diagram for a static technical explanation when the
interface supports it. Use available visualization tools for interaction when
it materially helps. Do not build a website for an ordinary explanation unless
requested. Follow the environment's artifact and plotting rules when producing
figures. If a visual cannot be rendered, use a short numbered walkthrough.

Explain what the reader should notice in the visual. Keep labels consistent
with the prose, and distinguish measured data from illustrative values. Skip
decorative images and diagrams that repeat a sentence without clarifying it.

## Example: preserve uncertainty while removing jargon

Hypothetical source:

> The observed timeout may be attributable to contention in the connection pool.
> All connections were in use when the request arrived, but we did not measure
> how long it waited for one.

Rewrite:

> All connections were in use when the request arrived. The request may have
> timed out while waiting for a free connection. We did not measure that wait,
> so we cannot confirm the cause.

The rewrite keeps the observation, possible explanation, and missing evidence
separate. A shorter claim that the connection pool caused the timeout would
change the meaning.

## Check before replying

Check whether the reader can identify what happens and why. Remove unexplained
terms, ambiguous pronouns, and sentences that add no information. Compare a
rewrite with its source for lost conditions, changed certainty, or invented
facts. Check that any diagram agrees with the explanation.

## Sources and scope

This local guidance draws on the separation of chat and document rules in
[SimpleEnglish](https://github.com/AminBlg/SimpleEnglish/blob/main/skills/simple-english/SKILL.md)
and its
[standalone prompt](https://github.com/AminBlg/SimpleEnglish/blob/main/prompts/system-prompt.md),
reviewed on 2026-11-15. The wording and hypothetical example here are local.
We retain uncertainty, allow natural grammar, and choose length and formatting
according to the question instead of importing every upstream restriction.

For an explicit request for strict ASD-STE100 compliance, consult the
[official specification](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf).
Do not treat this skill, or a request merely mentioning STE, as a compliance
check. Research-paper structure, citations, and rendering checks remain in
`paper-writing`.
