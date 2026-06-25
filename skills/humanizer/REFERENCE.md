# Humanizer — Reference

See [SKILL.md](SKILL.md) for quick reference, quick start, and workflow.

## Voice Calibration (Optional)

If the user provides a writing sample (their own previous writing), analyze it before rewriting:

1. **Read the sample first.** Note:
   - Sentence length patterns (short and punchy? Long and flowing? Mixed?)
   - Word choice level (casual? academic? somewhere between?)
   - How they start paragraphs (jump right in? Set context first?)
   - Punctuation habits (lots of dashes? Parenthetical asides? Semicolons?)
   - Any recurring phrases or verbal tics
   - How they handle transitions (explicit connectors? Just start the next point?)

2. **Match their voice in the rewrite.** Don't just remove AI patterns — replace them with patterns from the sample. If they write short sentences, don't produce long ones. If they use "stuff" and "things," don't upgrade to "elements" and "components."

3. **When no sample is provided,** fall back to the default behavior (natural, varied, opinionated voice).

## Personality and Soul

Avoiding AI patterns is only half the job. Sterile, voiceless writing is just as obvious as slop.

**Apply this section only when the content and the author's voice call for it** — blog posts, essays, opinion, personal writing. For encyclopedic, technical, legal, or reference text, neutral and plain *is* the correct human voice.

### Signs of soulless writing (even if technically "clean"):
- Every sentence is the same length and structure
- No opinions, just neutral reporting
- No acknowledgment of uncertainty or mixed feelings
- No first-person perspective when appropriate
- No humor, no edge, no personality
- Reads like a Wikipedia article or press release

### How to add voice:
**Have opinions.** Don't just report facts — react to them.
**Vary your rhythm.** Short punchy sentences. Then longer ones.
**Let some mess in.** Tangents, asides, and half-formed thoughts are human.

## Content Patterns (1-6)

### 1. Undue Emphasis on Significance, Legacy, and Broader Trends
**Words to watch:** stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal/key role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted

**Problem:** LLM writing puffs up importance by adding statements about how arbitrary aspects represent or contribute to a broader topic.

**Before:**
> The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain.

**After:**
> The Statistical Institute of Catalonia was established in 1989 to collect and publish regional statistics independently from Spain's national statistics office.

### 2. Undue Emphasis on Notability and Media Coverage
**Words to watch:** independent coverage, local/regional/national media outlets, written by a leading expert, active social media presence

**Problem:** LLMs hit readers over the head with claims of notability.

**Before:**
> Her views have been cited in The New York Times, BBC, Financial Times, and The Hindu.

**After:**
> In a 2024 New York Times interview, she argued that AI regulation should focus on outcomes rather than methods.

### 3. Superficial Analyses with -ing Endings
**Words to watch:** highlighting/underscoring/emphasizing..., ensuring..., reflecting/symbolizing..., contributing to..., cultivating/fostering..., encompassing..., showcasing...

**Problem:** AI chatbots tack present participle ("-ing") phrases onto sentences.

**Before:**
> The temple's color palette of blue, green, and gold resonates with the region's natural beauty, symbolizing Texas bluebonnets...

**After:**
> The temple uses blue, green, and gold colors. The architect said these were chosen to reference local bluebonnets.

### 4. Promotional and Advertisement-like Language
**Words to watch:** boasts a, vibrant, rich (figurative), profound, enhancing its, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning

**Problem:** LLMs have trouble keeping a neutral tone.

**Before:**
> Nestled within the breathtaking region of Gonder in Ethiopia...

**After:**
> Alamata Raya Kobo is a town in the Gonder region of Ethiopia, known for its weekly market.

### 5. Vague Attributions and Weasel Words
**Words to watch:** Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when few cited)

**Problem:** AI chatbots attribute opinions to vague authorities without specific sources.

**Before:**
> Experts believe it plays a crucial role in the regional ecosystem.

**After:**
> The Haolai River supports several endemic fish species, according to a 2019 survey by the Chinese Academy of Sciences.

### 6. Outline-like "Challenges and Future Prospects" Sections
**Words to watch:** Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook

**Problem:** Formulaic "Challenges" sections.

**Before:**
> Despite its industrial prosperity, Korattur faces challenges typical of urban areas... Despite these challenges... Korattur continues to thrive.

**After:**
> Traffic congestion increased after 2015 when three new IT parks opened.

## Language and Grammar Patterns (7-13)

### 7. Overused "AI Vocabulary" Words
**High-frequency AI words:** Actually, additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract noun), pivotal, showcase, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant

**Problem:** These words appear far more frequently in post-2023 text.

**Before:**
> Additionally, a distinctive feature of Somali cuisine is the incorporation of camel meat. An enduring testament to Italian colonial influence is the widespread adoption of pasta...

**After:**
> Somali cuisine also includes camel meat, which is considered a delicacy.

### 8. Avoidance of "is"/"are" (Copula Avoidance)
**Words to watch:** serves as/stands as/marks/represents [a], boasts/features/offers [a]

**Before:**
> Gallery 825 serves as LAAA's exhibition space... features four separate spaces and boasts over 3,000 square feet.

**After:**
> Gallery 825 is LAAA's exhibition space. The gallery has four rooms totaling 3,000 square feet.

### 9. Negative Parallelisms and Tailing Negations
**Before:**
> It's not just about the beat... it's part of the aggression. It's not merely a song, it's a statement.

**After:**
> The heavy beat adds to the aggressive tone.

### 10. Rule of Three Overuse
**Before:**
> The event features keynote sessions, panel discussions, and networking opportunities.

**After:**
> The event includes talks and panels. There's also time for informal networking.

### 11. Elegant Variation (Synonym Cycling)
**Before:**
> The protagonist faces many challenges. The main character must overcome obstacles. The central figure eventually triumphs.

**After:**
> The protagonist faces many challenges but eventually triumphs and returns home.

### 12. False Ranges
**Before:**
> from the singularity of the Big Bang to the grand cosmic web, from the birth and death of stars to the enigmatic dance of dark matter

**After:**
> The book covers the Big Bang, star formation, and current theories about dark matter.

### 13. Passive Voice and Subjectless Fragments
**Before:**
> No configuration file needed. The results are preserved automatically.

**After:**
> You do not need a configuration file. The system preserves the results automatically.

## Style Patterns (14-19)

### 14. Em Dashes: Cut Them
**Rule:** The final rewrite contains no em dashes (—) or en dashes (–). Replace with period, comma, colon, or parentheses.

### 15. Overuse of Boldface
**Rule:** Do not mechanically bold key phrases.

### 16. Inline-Header Vertical Lists
**Rule:** Rewrite bolded-header lists as plain prose.

### 17. Title Case in Headings
**Rule:** Use sentence case, not title case.

### 18. Emojis
**Rule:** Do not decorate headings or bullets with emojis.

### 19. Curly Quotation Marks
**Rule:** Use straight quotes ("..."), not curly quotes (“...”).

## Communication Patterns (20-22)

### 20. Collaborative Communication Artifacts
**Words to watch:** I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., let me know, here is a...

### 21. Knowledge-Cutoff Disclaimers and Speculative Gap-Filling
**Words to watch:** as of [date], Up to my last training update, While specific details are limited, based on available information, not publicly available, maintains a low profile, keeps personal details private, prefers to stay out of the spotlight

### 22. Sycophantic/Servile Tone
**Before:**
> Great question! You're absolutely right that this is a complex topic.

**After:**
> The economic factors you mentioned are relevant here.

## Filler and Hedging (23-27)

### 23. Filler Phrases
- "In order to achieve this goal" → "To achieve this"
- "Due to the fact that it was raining" → "Because it was raining"
- "At this point in time" → "Now"
- "The system has the ability to process" → "The system can process"
- "It is important to note that the data shows" → "The data shows"

### 24. Excessive Hedging
**Before:** > It could potentially possibly be argued that the policy might have some effect.

**After:** > The policy may affect outcomes.

### 25. Generic Positive Conclusions
**Before:** > The future looks bright... Exciting times lie ahead...

**After:** > The company plans to open two more locations next year.

### 26. Hyphenated Word Pair Overuse
**Rule:** Keep attributive-position hyphens; drop them when the compound follows the noun.

**Before:** The report is high-quality. **After:** The report is high quality.

### 27. Persuasive Authority Tropes
**Phrases to watch:** The real question is, at its core, in reality, what really matters, fundamentally, the deeper issue, the heart of the matter

### 28. Signposting and Announcements
**Phrases to watch:** Let's dive in, let's explore, let's break this down, here's what you need to know

### 29. Fragmented Headers
**Rule:** A heading followed by a one-line restatement = padding. Delete the restatement.

### 30. Diff-Anchored Writing
**Rule:** Unless the document is version-scoped, describe the thing as it is, not how it changed.

## Detection Guidance

### What NOT to flag (false positives)
Before rewriting, sanity-check that you are not gutting legitimate prose:
- **Perfect grammar and consistent style.** Many writers are professionals.
- **Mixed casual and formal registers.** Often signals a person in a technical field.
- **"Bland" or "robotic" prose.** AI prose has *specific* tells, not generic dryness.
- **Formal or academic vocabulary.** AI overuses *specific* fancy words, not all fancy words.
- **Letter-style opening or closing** — predate ChatGPT by centuries.
- **Common transition words in isolation.** One *however* is not a tell.
- **Curly quotes alone.** macOS, Word, Google Docs auto-curl by default.
- **Em dashes alone.** Many editors use them often.
- **Unsourced claims.** Most of the web is unsourced.
- **Correct, complex formatting.** Visual editors produce clean output.

When in doubt, look for **clusters** of tells, not isolated ones.

### Signs of human writing (preserve these)
- Specific, unusual, hard-to-fabricate detail
- Mixed feelings and unresolved tension
- Dated, era-bound references
- First-person editorial choices the writer can defend
- Variety in sentence length
- Genuine asides, parentheticals, or self-corrections
- Edits made before November 30, 2022

## Full Example

**Before (AI-sounding):**
> Great question! Here is an essay on this topic. I hope this helps!
> AI-assisted coding serves as an enduring testament to the transformative potential of large language models, marking a pivotal moment in the evolution of software development...
> [Full example in original SKILL.md backup]

**Process:**
1. Read input, identify patterns
2. Write draft rewrite
3. Ask: "What makes this obviously AI generated?"
4. Revise into final rewrite with no em dashes

## Reference

This skill is based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup.
