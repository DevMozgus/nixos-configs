# OpenCode skills — each skill placed in ~/.config/opencode/skills/<name>/SKILL.md
{ ... }:
{
  xdg.configFile."opencode/skills/frontend-design/SKILL.md".text = ''

    ---
    name: frontend-design
    description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
    license: Complete terms in LICENSE.txt
    ---

    This skill guides creation of distinctive, production-grade frontend interfaces
    that avoid generic "AI slop" aesthetics. Implement real working code with
    exceptional attention to aesthetic details and creative choices.

    The user provides frontend requirements: a component, page, application, or
    interface to build. They may include context about the purpose, audience, or
    technical constraints.

    ## Design Thinking

    Before coding, understand the context and commit to a BOLD aesthetic direction:
    - **Purpose**: What problem does this interface solve? Who uses it?
    - **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
    - **Constraints**: Technical requirements (framework, performance, accessibility).
    - **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

    **CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

    Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
    - Production-grade and functional
    - Visually striking and memorable
    - Cohesive with a clear aesthetic point-of-view
    - Meticulously refined in every detail

    ## Frontend Aesthetics Guidelines

    Focus on:
    - **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
    - **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
    - **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
    - **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
    - **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

    NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

    Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

    **IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

    Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
  '';

  xdg.configFile."opencode/skills/animate/SKILL.md".text = ''
    ---
    name: animate
    description: Review a feature and enhance it with purposeful animations, micro-interactions, and motion effects that improve usability and delight. Use when the user mentions adding animation, transitions, micro-interactions, motion design, hover effects, or making the UI feel more alive.
    version: 2.1.1
    user-invocable: true
    argument-hint: "[target]"
    ---

    Analyze a feature and strategically add animations and micro-interactions that enhance understanding, provide feedback, and create delight.

    ## MANDATORY PREPARATION

    Invoke /impeccable — it contains design principles, anti-patterns, and the **Context Gathering Protocol**. Follow the protocol before proceeding — if no design context exists yet, you MUST run /impeccable teach first. Additionally gather: performance constraints.

    ---

    ## Assess Animation Opportunities

    Analyze where motion would improve the experience:

    1. **Identify static areas**:
       - **Missing feedback**: Actions without visual acknowledgment (button clicks, form submission, etc.)
       - **Jarring transitions**: Instant state changes that feel abrupt (show/hide, page loads, route changes)
       - **Unclear relationships**: Spatial or hierarchical relationships that aren't obvious
       - **Lack of delight**: Functional but joyless interactions
       - **Missed guidance**: Opportunities to direct attention or explain behavior

    2. **Understand the context**:
       - What's the personality? (Playful vs serious, energetic vs calm)
       - What's the performance budget? (Mobile-first? Complex page?)
       - Who's the audience? (Motion-sensitive users? Power users who want speed?)
       - What matters most? (One hero animation vs many micro-interactions?)

    If any of these are unclear from the codebase, STOP and call the `question` tool to clarify.

    **CRITICAL**: Respect `prefers-reduced-motion`. Always provide non-animated alternatives for users who need them.

    ## Plan Animation Strategy

    Create a purposeful animation plan:

    - **Hero moment**: What's the ONE signature animation? (Page load? Hero section? Key interaction?)
    - **Feedback layer**: Which interactions need acknowledgment?
    - **Transition layer**: Which state changes need smoothing?
    - **Delight layer**: Where can we surprise and delight?

    **IMPORTANT**: One well-orchestrated experience beats scattered animations everywhere. Focus on high-impact moments.

    ## Implement Animations

    Add motion systematically across these categories:

    ### Entrance Animations
    - **Page load choreography**: Stagger element reveals (100-150ms delays), fade + slide combinations
    - **Hero section**: Dramatic entrance for primary content (scale, parallax, or creative effects)
    - **Content reveals**: Scroll-triggered animations using intersection observer
    - **Modal/drawer entry**: Smooth slide + fade, backdrop fade, focus management

    ### Micro-interactions
    - **Button feedback**:
      - Hover: Subtle scale (1.02-1.05), color shift, shadow increase
      - Click: Quick scale down then up (0.95 → 1), ripple effect
      - Loading: Spinner or pulse state
    - **Form interactions**:
      - Input focus: Border color transition, slight scale or glow
      - Validation: Shake on error, check mark on success, smooth color transitions
    - **Toggle switches**: Smooth slide + color transition (200-300ms)
    - **Checkboxes/radio**: Check mark animation, ripple effect
    - **Like/favorite**: Scale + rotation, particle effects, color transition

    ### State Transitions
    - **Show/hide**: Fade + slide (not instant), appropriate timing (200-300ms)
    - **Expand/collapse**: Height transition with overflow handling, icon rotation
    - **Loading states**: Skeleton screen fades, spinner animations, progress bars
    - **Success/error**: Color transitions, icon animations, gentle scale pulse
    - **Enable/disable**: Opacity transitions, cursor changes

    ### Navigation & Flow
    - **Page transitions**: Crossfade between routes, shared element transitions
    - **Tab switching**: Slide indicator, content fade/slide
    - **Carousel/slider**: Smooth transforms, snap points, momentum
    - **Scroll effects**: Parallax layers, sticky headers with state changes, scroll progress indicators

    ### Feedback & Guidance
    - **Hover hints**: Tooltip fade-ins, cursor changes, element highlights
    - **Drag & drop**: Lift effect (shadow + scale), drop zone highlights, smooth repositioning
    - **Copy/paste**: Brief highlight flash on paste, "copied" confirmation
    - **Focus flow**: Highlight path through form or workflow

    ### Delight Moments
    - **Empty states**: Subtle floating animations on illustrations
    - **Completed actions**: Confetti, check mark flourish, success celebrations
    - **Easter eggs**: Hidden interactions for discovery
    - **Contextual animation**: Weather effects, time-of-day themes, seasonal touches

    ## Technical Implementation

    Use appropriate techniques for each animation:

    ### Timing & Easing

    **Durations by purpose:**
    - **100-150ms**: Instant feedback (button press, toggle)
    - **200-300ms**: State changes (hover, menu open)
    - **300-500ms**: Layout changes (accordion, modal)
    - **500-800ms**: Entrance animations (page load)

    **Easing curves (use these, not CSS defaults):**
    ```css
    /* Recommended - natural deceleration */
    --ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);    /* Smooth, refined */
    --ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);   /* Slightly snappier */
    --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);     /* Confident, decisive */

    /* AVOID - feel dated and tacky */
    /* bounce: cubic-bezier(0.34, 1.56, 0.64, 1); */
    /* elastic: cubic-bezier(0.68, -0.6, 0.32, 1.6); */
    ```

    **Exit animations are faster than entrances.** Use ~75% of enter duration.

    ### CSS Animations
    ```css
    /* Prefer for simple, declarative animations */
    - transitions for state changes
    - @keyframes for complex sequences
    - transform + opacity only (GPU-accelerated)
    ```

    ### JavaScript Animation
    ```javascript
    /* Use for complex, interactive animations */
    - Web Animations API for programmatic control
    - Framer Motion for React
    - GSAP for complex sequences
    ```

    ### Performance
    - **GPU acceleration**: Use `transform` and `opacity`, avoid layout properties
    - **will-change**: Add sparingly for known expensive animations
    - **Reduce paint**: Minimize repaints, use `contain` where appropriate
    - **Monitor FPS**: Ensure 60fps on target devices

    ### Accessibility
    ```css
    @media (prefers-reduced-motion: reduce) {
      * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
      }
    }
    ```

    **NEVER**:
    - Use bounce or elastic easing curves—they feel dated and draw attention to the animation itself
    - Animate layout properties (width, height, top, left)—use transform instead
    - Use durations over 500ms for feedback—it feels laggy
    - Animate without purpose—every animation needs a reason
    - Ignore `prefers-reduced-motion`—this is an accessibility violation
    - Animate everything—animation fatigue makes interfaces feel exhausting
    - Block interaction during animations unless intentional

    ## Verify Quality

    Test animations thoroughly:

    - **Smooth at 60fps**: No jank on target devices
    - **Feels natural**: Easing curves feel organic, not robotic
    - **Appropriate timing**: Not too fast (jarring) or too slow (laggy)
    - **Reduced motion works**: Animations disabled or simplified appropriately
    - **Doesn't block**: Users can interact during/after animations
    - **Adds value**: Makes interface clearer or more delightful

    Remember: Motion should enhance understanding and provide feedback, not just add decoration. Animate with purpose, respect performance constraints, and always consider accessibility. Great animation is invisible - it just makes everything feel right.
  '';

  xdg.configFile."opencode/skills/audit/SKILL.md".text = ''
    ---
    name: audit
    description: Run technical quality checks across accessibility, performance, theming, responsive design, and anti-patterns. Generates a scored report with P0-P3 severity ratings and actionable plan. Use when the user wants an accessibility check, performance audit, or technical quality review.
    version: 2.1.1
    user-invocable: true
    argument-hint: "[area (feature, page, component...)]"
    ---

    ## MANDATORY PREPARATION

    Invoke /impeccable — it contains design principles, anti-patterns, and the **Context Gathering Protocol**. Follow the protocol before proceeding — if no design context exists yet, you MUST run /impeccable teach first.

    ---

    Run systematic **technical** quality checks and generate a comprehensive report. Don't fix issues — document them for other commands to address.

    This is a code-level audit, not a design critique. Check what's measurable and verifiable in the implementation.

    ## Diagnostic Scan

    Run comprehensive checks across 5 dimensions. Score each dimension 0-4 using the criteria below.

    ### 1. Accessibility (A11y)

    **Check for**:
    - **Contrast issues**: Text contrast ratios < 4.5:1 (or 7:1 for AAA)
    - **Missing ARIA**: Interactive elements without proper roles, labels, or states
    - **Keyboard navigation**: Missing focus indicators, illogical tab order, keyboard traps
    - **Semantic HTML**: Improper heading hierarchy, missing landmarks, divs instead of buttons
    - **Alt text**: Missing or poor image descriptions
    - **Form issues**: Inputs without labels, poor error messaging, missing required indicators

    **Score 0-4**: 0=Inaccessible (fails WCAG A), 1=Major gaps (few ARIA labels, no keyboard nav), 2=Partial (some a11y effort, significant gaps), 3=Good (WCAG AA mostly met, minor gaps), 4=Excellent (WCAG AA fully met, approaches AAA)

    ### 2. Performance

    **Check for**:
    - **Layout thrashing**: Reading/writing layout properties in loops
    - **Expensive animations**: Animating layout properties (width, height, top, left) instead of transform/opacity
    - **Missing optimization**: Images without lazy loading, unoptimized assets, missing will-change
    - **Bundle size**: Unnecessary imports, unused dependencies
    - **Render performance**: Unnecessary re-renders, missing memoization

    **Score 0-4**: 0=Severe issues (layout thrash, unoptimized everything), 1=Major problems (no lazy loading, expensive animations), 2=Partial (some optimization, gaps remain), 3=Good (mostly optimized, minor improvements possible), 4=Excellent (fast, lean, well-optimized)

    ### 3. Theming

    **Check for**:
    - **Hard-coded colors**: Colors not using design tokens
    - **Broken dark mode**: Missing dark mode variants, poor contrast in dark theme
    - **Inconsistent tokens**: Using wrong tokens, mixing token types
    - **Theme switching issues**: Values that don't update on theme change

    **Score 0-4**: 0=No theming (hard-coded everything), 1=Minimal tokens (mostly hard-coded), 2=Partial (tokens exist but inconsistently used), 3=Good (tokens used, minor hard-coded values), 4=Excellent (full token system, dark mode works perfectly)

    ### 4. Responsive Design

    **Check for**:
    - **Fixed widths**: Hard-coded widths that break on mobile
    - **Touch targets**: Interactive elements < 44x44px
    - **Horizontal scroll**: Content overflow on narrow viewports
    - **Text scaling**: Layouts that break when text size increases
    - **Missing breakpoints**: No mobile/tablet variants

    **Score 0-4**: 0=Desktop-only (breaks on mobile), 1=Major issues (some breakpoints, many failures), 2=Partial (works on mobile, rough edges), 3=Good (responsive, minor touch target or overflow issues), 4=Excellent (fluid, all viewports, proper touch targets)

    ### 5. Anti-Patterns (CRITICAL)

    Check against ALL the **DON'T** guidelines in the impeccable skill. Look for AI slop tells (AI color palette, gradient text, glassmorphism, hero metrics, card grids, generic fonts) and general design anti-patterns (gray on color, nested cards, bounce easing, redundant copy).

    **Score 0-4**: 0=AI slop gallery (5+ tells), 1=Heavy AI aesthetic (3-4 tells), 2=Some tells (1-2 noticeable), 3=Mostly clean (subtle issues only), 4=No AI tells (distinctive, intentional design)

    ## Generate Report

    ### Audit Health Score

    | # | Dimension | Score | Key Finding |
    |---|-----------|-------|-------------|
    | 1 | Accessibility | ? | [most critical a11y issue or "--"] |
    | 2 | Performance | ? | |
    | 3 | Responsive Design | ? | |
    | 4 | Theming | ? | |
    | 5 | Anti-Patterns | ? | |
    | **Total** | | **??/20** | **[Rating band]** |

    **Rating bands**: 18-20 Excellent (minor polish), 14-17 Good (address weak dimensions), 10-13 Acceptable (significant work needed), 6-9 Poor (major overhaul), 0-5 Critical (fundamental issues)

    ### Anti-Patterns Verdict
    **Start here.** Pass/fail: Does this look AI-generated? List specific tells. Be brutally honest.

    ### Executive Summary
    - Audit Health Score: **??/20** ([rating band])
    - Total issues found (count by severity: P0/P1/P2/P3)
    - Top 3-5 critical issues
    - Recommended next steps

    ### Detailed Findings by Severity

    Tag every issue with **P0-P3 severity**:
    - **P0 Blocking**: Prevents task completion — fix immediately
    - **P1 Major**: Significant difficulty or WCAG AA violation — fix before release
    - **P2 Minor**: Annoyance, workaround exists — fix in next pass
    - **P3 Polish**: Nice-to-fix, no real user impact — fix if time permits

    For each issue, document:
    - **[P?] Issue name**
    - **Location**: Component, file, line
    - **Category**: Accessibility / Performance / Theming / Responsive / Anti-Pattern
    - **Impact**: How it affects users
    - **WCAG/Standard**: Which standard it violates (if applicable)
    - **Recommendation**: How to fix it
    - **Suggested command**: Which command to use (prefer: /animate, /quieter, /shape, /optimize, /adapt, /clarify, /layout, /distill, /delight, /audit, /harden, /polish, /bolder, /typeset, /critique, /colorize, /overdrive)

    ### Patterns & Systemic Issues

    Identify recurring problems that indicate systemic gaps rather than one-off mistakes:
    - "Hard-coded colors appear in 15+ components, should use design tokens"
    - "Touch targets consistently too small (<44px) throughout mobile experience"

    ### Positive Findings

    Note what's working well — good practices to maintain and replicate.

    ## Recommended Actions

    List recommended commands in priority order (P0 first, then P1, then P2):

    1. **[P?] `/command-name`** — Brief description (specific context from audit findings)
    2. **[P?] `/command-name`** — Brief description (specific context)

    **Rules**: Only recommend commands from: /animate, /quieter, /shape, /optimize, /adapt, /clarify, /layout, /distill, /delight, /audit, /harden, /polish, /bolder, /typeset, /critique, /colorize, /overdrive. Map findings to the most appropriate command. End with `/polish` as the final step if any fixes were recommended.

    After presenting the summary, tell the user:

    > You can ask me to run these one at a time, all at once, or in any order you prefer.
    >
    > Re-run `/audit` after fixes to see your score improve.

    **IMPORTANT**: Be thorough but actionable. Too many P3 issues creates noise. Focus on what actually matters.

    **NEVER**:
    - Report issues without explaining impact (why does this matter?)
    - Provide generic recommendations (be specific and actionable)
    - Skip positive findings (celebrate what works)
    - Forget to prioritize (everything can't be P0)
    - Report false positives without verification

    Remember: You're a technical quality auditor. Document systematically, prioritize ruthlessly, cite specific code locations, and provide clear paths to improvement.
  '';

  xdg.configFile."opencode/skills/accessibility/SKILL.md".text = ''
    ---
    name: accessibility
    description: Audit and improve web accessibility following WCAG 2.2 guidelines. Use when asked to "improve accessibility", "a11y audit", "WCAG compliance", "screen reader support", "keyboard navigation", or "make accessible".
    license: MIT
    metadata:
      author: web-quality-skills
      version: "1.1"
    ---

    # Accessibility (a11y)

    Comprehensive accessibility guidelines based on WCAG 2.2 and Lighthouse accessibility audits. Goal: make content usable by everyone, including people with disabilities.

    ## WCAG Principles: POUR

    | Principle | Description |
    |-----------|-------------|
    | **P**erceivable | Content can be perceived through different senses |
    | **O**perable | Interface can be operated by all users |
    | **U**nderstandable | Content and interface are understandable |
    | **R**obust | Content works with assistive technologies |

    ## Conformance levels

    | Level | Requirement | Target |
    |-------|-------------|--------|
    | **A** | Minimum accessibility | Must pass |
    | **AA** | Standard compliance | Should pass (legal requirement in many jurisdictions) |
    | **AAA** | Enhanced accessibility | Nice to have |

    ---

    ## Perceivable

    ### Text alternatives (1.1)

    **Images require alt text:**
    ```html
    <!-- ❌ Missing alt -->
    <img src="chart.png">

    <!-- ✅ Descriptive alt -->
    <img src="chart.png" alt="Bar chart showing 40% increase in Q3 sales">

    <!-- ✅ Decorative image (empty alt) -->
    <img src="decorative-border.png" alt="" role="presentation">

    <!-- ✅ Complex image with longer description -->
    <figure>
      <img src="infographic.png" alt="2024 market trends infographic" 
           aria-describedby="infographic-desc">
      <figcaption id="infographic-desc">
        <!-- Detailed description -->
      </figcaption>
    </figure>
    ```

    **Icon buttons need accessible names:**
    ```html
    <!-- ❌ No accessible name -->
    <button><svg><!-- menu icon --></svg></button>

    <!-- ✅ Using aria-label -->
    <button aria-label="Open menu">
      <svg aria-hidden="true"><!-- menu icon --></svg>
    </button>

    <!-- ✅ Using visually hidden text -->
    <button>
      <svg aria-hidden="true"><!-- menu icon --></svg>
      <span class="visually-hidden">Open menu</span>
    </button>
    ```

    **Visually hidden class:**
    ```css
    .visually-hidden {
      position: absolute;
      width: 1px;
      height: 1px;
      padding: 0;
      margin: -1px;
      overflow: hidden;
      clip: rect(0, 0, 0, 0);
      white-space: nowrap;
      border: 0;
    }
    ```

    ### Color contrast (1.4.3, 1.4.6)

    | Text Size | AA minimum | AAA enhanced |
    |-----------|------------|--------------|
    | Normal text (< 18px / < 14px bold) | 4.5:1 | 7:1 |
    | Large text (≥ 18px / ≥ 14px bold) | 3:1 | 4.5:1 |
    | UI components & graphics | 3:1 | 3:1 |

    ```css
    /* ❌ Low contrast (2.5:1) */
    .low-contrast {
      color: #999;
      background: #fff;
    }

    /* ✅ Sufficient contrast (7:1) */
    .high-contrast {
      color: #333;
      background: #fff;
    }

    /* ✅ Focus states need contrast too */
    :focus-visible {
      outline: 2px solid #005fcc;
      outline-offset: 2px;
    }
    ```

    **Don't rely on color alone:**
    ```html
    <!-- ❌ Only color indicates error -->
    <input class="error-border">
    <style>.error-border { border-color: red; }</style>

    <!-- ✅ Color + icon + text -->
    <div class="field-error">
      <input aria-invalid="true" aria-describedby="email-error">
      <span id="email-error" class="error-message">
        <svg aria-hidden="true"><!-- error icon --></svg>
        Please enter a valid email address
      </span>
    </div>
    ```

    ### Media alternatives (1.2)

    ```html
    <!-- Video with captions -->
    <video controls>
      <source src="video.mp4" type="video/mp4">
      <track kind="captions" src="captions.vtt" srclang="en" label="English" default>
      <track kind="descriptions" src="descriptions.vtt" srclang="en" label="Descriptions">
    </video>

    <!-- Audio with transcript -->
    <audio controls>
      <source src="podcast.mp3" type="audio/mp3">
    </audio>
    <details>
      <summary>Transcript</summary>
      <p>Full transcript text...</p>
    </details>
    ```

    ---

    ## Operable

    ### Keyboard accessible (2.1)

    **All functionality must be keyboard accessible:**
    ```javascript
    // ❌ Only handles click
    element.addEventListener('click', handleAction);

    // ✅ Handles both click and keyboard
    element.addEventListener('click', handleAction);
    element.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        handleAction();
      }
    });
    ```

    **No keyboard traps.** Users must be able to Tab into and out of every component. Use the [modal focus trap pattern](references/A11Y-PATTERNS.md#modal-focus-trap) for dialogs—the native `<dialog>` element handles this automatically.

    ### Focus visible (2.4.7)

    ```css
    /* ❌ Never remove focus outlines */
    *:focus { outline: none; }

    /* ✅ Use :focus-visible for keyboard-only focus */
    :focus {
      outline: none;
    }

    :focus-visible {
      outline: 2px solid #005fcc;
      outline-offset: 2px;
    }

    /* ✅ Or custom focus styles */
    button:focus-visible {
      box-shadow: 0 0 0 3px rgba(0, 95, 204, 0.5);
    }
    ```

    ### Focus not obscured (2.4.11) — new in 2.2

    When an element receives keyboard focus, it must not be entirely hidden by other author-created content such as sticky headers, footers, or overlapping panels. At Level AAA (2.4.12), no part of the focused element may be hidden.

    ```css
    /* ✅ Account for sticky headers when scrolling to focused elements */
    :target {
      scroll-margin-top: 80px;
    }

    /* ✅ Ensure focused items clear fixed/sticky bars */
    :focus {
      scroll-margin-top: 80px;
      scroll-margin-bottom: 60px;
    }
    ```

    ### Skip links (2.4.1)

    Provide a skip link so keyboard users can bypass repetitive navigation. See the [skip link pattern](references/A11Y-PATTERNS.md#skip-link) for full markup and styles.

    ### Target size (2.5.8) — new in 2.2

    Interactive targets must be at least **24 × 24 CSS pixels** (AA). Exceptions: inline text links, elements where the browser controls the size, and targets where a 24px circle centered on the bounding box does not overlap another target.

    ```css
    /* ✅ Minimum target size */
    button,
    [role="button"],
    input[type="checkbox"] + label,
    input[type="radio"] + label {
      min-width: 24px;
      min-height: 24px;
    }

    /* ✅ Comfortable target size (recommended 44×44) */
    .touch-target {
      min-width: 44px;
      min-height: 44px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
    ```

    ### Dragging movements (2.5.7) — new in 2.2

    Any action that requires dragging must have a single-pointer alternative (e.g., buttons, inputs). See the [dragging movements pattern](references/A11Y-PATTERNS.md#dragging-movements) for a sortable-list example.

    ### Timing (2.2)

    ```javascript
    // Allow users to extend time limits
    function showSessionWarning() {
      const modal = createModal({
        title: 'Session Expiring',
        content: 'Your session will expire in 2 minutes.',
        actions: [
          { label: 'Extend session', action: extendSession },
          { label: 'Log out', action: logout }
        ],
        timeout: 120000
      });
    }
    ```

    ### Motion (2.3)

    ```css
    /* Respect reduced motion preference */
    @media (prefers-reduced-motion: reduce) {
      *,
      *::before,
      *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
        scroll-behavior: auto !important;
      }
    }
    ```

    ---

    ## Understandable

    ### Page language (3.1.1)

    ```html
    <!-- ❌ No language specified -->
    <html>

    <!-- ✅ Language specified -->
    <html lang="en">

    <!-- ✅ Language changes within page -->
    <p>The French word for hello is <span lang="fr">bonjour</span>.</p>
    ```

    ### Consistent navigation (3.2.3)

    ```html
    <!-- Navigation should be consistent across pages -->
    <nav aria-label="Main">
      <ul>
        <li><a href="/" aria-current="page">Home</a></li>
        <li><a href="/products">Products</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </nav>
    ```

    ### Consistent help (3.2.6) — new in 2.2

    If a help mechanism (contact info, chat widget, FAQ link, self-help option) is repeated across multiple pages, it must appear in the **same relative order** each time. Users who rely on consistent placement shouldn't have to hunt for help on every page.

    ### Form labels (3.3.2)

    Every input needs a programmatically associated label. See the [form labels pattern](references/A11Y-PATTERNS.md#form-labels) for explicit, implicit, and instructional examples.

    ### Error handling (3.3.1, 3.3.3)

    Announce errors to screen readers with `role="alert"` or `aria-live`, set `aria-invalid="true"` on invalid fields, and focus the first error on submit. See the [error handling pattern](references/A11Y-PATTERNS.md#error-handling) for full markup and JS.

    ### Redundant entry (3.3.7) — new in 2.2

    Don't force users to re-enter information they already provided in the same session. Auto-populate from earlier steps, or let users select from previously entered values. Exceptions: security re-confirmation and content that has expired.

    ```html
    <!-- ✅ Auto-fill shipping address from billing -->
    <fieldset>
      <legend>Shipping address</legend>
      <label>
        <input type="checkbox" id="same-as-billing" checked>
        Same as billing address
      </label>
      <!-- Fields auto-populated when checked -->
    </fieldset>
    ```

    ### Accessible authentication (3.3.8) — new in 2.2

    Login flows must not rely on cognitive function tests (e.g., remembering a password, solving a puzzle) unless at least one of:
    - A copy-paste or autofill mechanism is available
    - An alternative method exists (e.g., passkey, SSO, email link)
    - The test uses object recognition or personal content (AA only; AAA removes this exception)

    ```html
    <!-- ✅ Allow paste in password fields -->
    <input type="password" id="password" autocomplete="current-password">

    <!-- ✅ Offer passwordless alternatives -->
    <button type="button">Sign in with passkey</button>
    <button type="button">Email me a login link</button>
    ```

    ---

    ## Robust

    ### ARIA usage (4.1.2)

    **Prefer native elements:**
    ```html
    <!-- ❌ ARIA role on div -->
    <div role="button" tabindex="0">Click me</div>

    <!-- ✅ Native button -->
    <button>Click me</button>

    <!-- ❌ ARIA checkbox -->
    <div role="checkbox" aria-checked="false">Option</div>

    <!-- ✅ Native checkbox -->
    <label><input type="checkbox"> Option</label>
    ```

    **When ARIA is needed,** use the correct roles and states. See the [ARIA tabs pattern](references/A11Y-PATTERNS.md#aria-tabs) for a complete tablist example.

    ### Live regions (4.1.3)

    Use `aria-live` regions to announce dynamic content changes without moving focus. See the [live regions pattern](references/A11Y-PATTERNS.md#live-regions-and-notifications) for markup and a `showNotification()` helper.

    ---

    ## Testing checklist

    ### Automated testing
    ```bash
    # Lighthouse accessibility audit
    npx lighthouse https://example.com --only-categories=accessibility

    # axe-core
    npm install @axe-core/cli -g
    axe https://example.com
    ```

    ### Manual testing

    - [ ] **Keyboard navigation:** Tab through entire page, use Enter/Space to activate
    - [ ] **Screen reader:** Test with VoiceOver (Mac), NVDA (Windows), or TalkBack (Android)
    - [ ] **Zoom:** Content usable at 200% zoom
    - [ ] **High contrast:** Test with Windows High Contrast Mode
    - [ ] **Reduced motion:** Test with `prefers-reduced-motion: reduce`
    - [ ] **Focus order:** Logical and follows visual order
    - [ ] **Target size:** Interactive elements meet 24×24px minimum

    See the [screen reader commands reference](references/A11Y-PATTERNS.md#screen-reader-commands) for VoiceOver and NVDA shortcuts.

    ---

    ## Common issues by impact

    ### Critical (fix immediately)
    1. Missing form labels
    2. Missing image alt text
    3. Insufficient color contrast
    4. Keyboard traps
    5. No focus indicators

    ### Serious (fix before launch)
    1. Missing page language
    2. Missing heading structure
    3. Non-descriptive link text
    4. Auto-playing media
    5. Missing skip links

    ### Moderate (fix soon)
    1. Missing ARIA labels on icons
    2. Inconsistent navigation
    3. Missing error identification
    4. Timing without controls
    5. Missing landmark regions

    ## References

    - [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
    - [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
    - [Deque axe Rules](https://dequeuniversity.com/rules/axe/)
    - [Web Quality Audit](../web-quality-audit/SKILL.md)
    - [WCAG criteria reference](references/WCAG.md)
    - [Accessibility code patterns](references/A11Y-PATTERNS.md)
  '';

  xdg.configFile."opencode/skills/architecture-patterns/SKILL.md".text = ''

  '';

  xdg.configFile."opencode/skills/copywriting/SKILL.md".text = ''
    ---
    name: copywriting
    description: When the user wants to write, rewrite, or improve marketing copy for any page — including homepage, landing pages, pricing pages, feature pages, about pages, or product pages. Also use when the user says "write copy for," "improve this copy," "rewrite this page," "marketing copy," "headline help," "CTA copy," "value proposition," "tagline," "subheadline," "hero section copy," "above the fold," "this copy is weak," "make this more compelling," or "help me describe my product." Use this whenever someone is working on website text that needs to persuade or convert. For email copy, see email-sequence. For popup copy, see popup-cro. For editing existing copy, see copy-editing.
    metadata:
      version: 1.1.0
    ---

    # Copywriting

    You are an expert conversion copywriter. Your goal is to write marketing copy that is clear, compelling, and drives action.

    ## Before Writing

    **Check for product marketing context first:**
    If `.agents/product-marketing-context.md` exists (or `.claude/product-marketing-context.md` in older setups), read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

    Gather this context (ask if not provided):

    ### 1. Page Purpose
    - What type of page? (homepage, landing page, pricing, feature, about)
    - What is the ONE primary action you want visitors to take?

    ### 2. Audience
    - Who is the ideal customer?
    - What problem are they trying to solve?
    - What objections or hesitations do they have?
    - What language do they use to describe their problem?

    ### 3. Product/Offer
    - What are you selling or offering?
    - What makes it different from alternatives?
    - What's the key transformation or outcome?
    - Any proof points (numbers, testimonials, case studies)?

    ### 4. Context
    - Where is traffic coming from? (ads, organic, email)
    - What do visitors already know before arriving?

    ---

    ## Copywriting Principles

    ### Clarity Over Cleverness
    If you have to choose between clear and creative, choose clear.

    ### Benefits Over Features
    Features: What it does. Benefits: What that means for the customer.

    ### Specificity Over Vagueness
    - Vague: "Save time on your workflow"
    - Specific: "Cut your weekly reporting from 4 hours to 15 minutes"

    ### Customer Language Over Company Language
    Use words your customers use. Mirror voice-of-customer from reviews, interviews, support tickets.

    ### One Idea Per Section
    Each section should advance one argument. Build a logical flow down the page.

    ---

    ## Writing Style Rules

    ### Core Principles

    1. **Simple over complex** — "Use" not "utilize," "help" not "facilitate"
    2. **Specific over vague** — Avoid "streamline," "optimize," "innovative"
    3. **Active over passive** — "We generate reports" not "Reports are generated"
    4. **Confident over qualified** — Remove "almost," "very," "really"
    5. **Show over tell** — Describe the outcome instead of using adverbs
    6. **Honest over sensational** — Fabricated statistics or testimonials erode trust and create legal liability

    ### Quick Quality Check

    - Jargon that could confuse outsiders?
    - Sentences trying to do too much?
    - Passive voice constructions?
    - Exclamation points? (remove them)
    - Marketing buzzwords without substance?

    For thorough line-by-line review, use the **copy-editing** skill after your draft.

    ---

    ## Best Practices

    ### Be Direct
    Get to the point. Don't bury the value in qualifications.

    ❌ Slack lets you share files instantly, from documents to images, directly in your conversations

    ✅ Need to share a screenshot? Send as many documents, images, and audio files as your heart desires.

    ### Use Rhetorical Questions
    Questions engage readers and make them think about their own situation.
    - "Hate returning stuff to Amazon?"
    - "Tired of chasing approvals?"

    ### Use Analogies When Helpful
    Analogies make abstract concepts concrete and memorable.

    ### Pepper in Humor (When Appropriate)
    Puns and wit make copy memorable—but only if it fits the brand and doesn't undermine clarity.

    ---

    ## Page Structure Framework

    ### Above the Fold

    **Headline**
    - Your single most important message
    - Communicate core value proposition
    - Specific > generic

    **Example formulas:**
    - "{Achieve outcome} without {pain point}"
    - "The {category} for {audience}"
    - "Never {unpleasant event} again"
    - "{Question highlighting main pain point}"

    **For comprehensive headline formulas**: See [references/copy-frameworks.md](references/copy-frameworks.md)

    **For natural transition phrases**: See [references/natural-transitions.md](references/natural-transitions.md)

    **Subheadline**
    - Expands on headline
    - Adds specificity
    - 1-2 sentences max

    **Primary CTA**
    - Action-oriented button text
    - Communicate what they get: "Start Free Trial" > "Sign Up"

    ### Core Sections

    | Section | Purpose |
    |---------|---------|
    | Social Proof | Build credibility (logos, stats, testimonials) |
    | Problem/Pain | Show you understand their situation |
    | Solution/Benefits | Connect to outcomes (3-5 key benefits) |
    | How It Works | Reduce perceived complexity (3-4 steps) |
    | Objection Handling | FAQ, comparisons, guarantees |
    | Final CTA | Recap value, repeat CTA, risk reversal |

    **For detailed section types and page templates**: See [references/copy-frameworks.md](references/copy-frameworks.md)

    ---

    ## CTA Copy Guidelines

    **Weak CTAs (avoid):**
    - Submit, Sign Up, Learn More, Click Here, Get Started

    **Strong CTAs (use):**
    - Start Free Trial
    - Get [Specific Thing]
    - See [Product] in Action
    - Create Your First [Thing]
    - Download the Guide

    **Formula:** [Action Verb] + [What They Get] + [Qualifier if needed]

    Examples:
    - "Start My Free Trial"
    - "Get the Complete Checklist"
    - "See Pricing for My Team"

    ---

    ## Page-Specific Guidance

    ### Homepage
    - Serve multiple audiences without being generic
    - Lead with broadest value proposition
    - Provide clear paths for different visitor intents

    ### Landing Page
    - Single message, single CTA
    - Match headline to ad/traffic source
    - Complete argument on one page

    ### Pricing Page
    - Help visitors choose the right plan
    - Address "which is right for me?" anxiety
    - Make recommended plan obvious

    ### Feature Page
    - Connect feature → benefit → outcome
    - Show use cases and examples
    - Clear path to try or buy

    ### About Page
    - Tell the story of why you exist
    - Connect mission to customer benefit
    - Still include a CTA

    ---

    ## Voice and Tone

    Before writing, establish:

    **Formality level:**
    - Casual/conversational
    - Professional but friendly
    - Formal/enterprise

    **Brand personality:**
    - Playful or serious?
    - Bold or understated?
    - Technical or accessible?

    Maintain consistency, but adjust intensity:
    - Headlines can be bolder
    - Body copy should be clearer
    - CTAs should be action-oriented

    ---

    ## Output Format

    When writing copy, provide:

    ### Page Copy
    Organized by section:
    - Headline, Subheadline, CTA
    - Section headers and body copy
    - Secondary CTAs

    ### Annotations
    For key elements, explain:
    - Why you made this choice
    - What principle it applies

    ### Alternatives
    For headlines and CTAs, provide 2-3 options:
    - Option A: [copy] — [rationale]
    - Option B: [copy] — [rationale]

    ### Meta Content (if relevant)
    - Page title (for SEO)
    - Meta description

    ---

    ## Related Skills

    - **copy-editing**: For polishing existing copy (use after your draft)
    - **page-cro**: If page structure/strategy needs work, not just copy
    - **email-sequence**: For email copywriting
    - **popup-cro**: For popup and modal copy
    - **ab-test-setup**: To test copy variations
  '';

  xdg.configFile."opencode/skills/documentation-writer/SKILL.md".text = ''
    ---
    description: "Technical documentation, README files, API docs, diagrams, walkthroughs."
    name: gem-documentation-writer
    disable-model-invocation: false
    user-invocable: false
    ---

    # Role

    DOCUMENTATION WRITER: Write technical docs, generate diagrams, maintain code-documentation parity. Never implement.

    # Expertise

    Technical Writing, API Documentation, Diagram Generation, Documentation Maintenance

    # Knowledge Sources

    1. `./docs/PRD.yaml` and related files
    2. Codebase patterns (semantic search, targeted reads)
    3. `AGENTS.md` for conventions
    4. Context7 for library docs
    5. Official docs and online search
    6. Existing documentation (README, docs/, CONTRIBUTING.md)

    # Workflow

    ## 1. Initialize
    - Read AGENTS.md if exists. Follow conventions.
    - Parse: task_type (walkthrough|documentation|update), task_id, plan_id, task_definition.

    ## 2. Execute (by task_type)

    ### 2.1 Walkthrough
    - Read task_definition (overview, tasks_completed, outcomes, next_steps).
    - Read docs/PRD.yaml for feature scope and acceptance criteria context.
    - Create docs/plan/{plan_id}/walkthrough-completion-{timestamp}.md.
    - Document: overview, tasks completed, outcomes, next steps.

    ### 2.2 Documentation
    - Read source code (read-only).
    - Read existing docs/README/CONTRIBUTING.md for style, structure, and tone conventions.
    - Draft documentation with code snippets.
    - Generate diagrams (ensure render correctly).
    - Verify against code parity.

    ### 2.3 Update
    - Read existing documentation to establish baseline.
    - Identify delta (what changed).
    - Verify parity on delta only.
    - Update existing documentation.
    - Ensure no TBD/TODO in final.

    ## 3. Validate
    - Use get_errors to catch and fix issues before verification.
    - Ensure diagrams render.
    - Check no secrets exposed.

    ## 4. Verify
    - Walkthrough: Verify against plan.yaml completeness.
    - Documentation: Verify code parity.
    - Update: Verify delta parity.

    ## 5. Self-Critique
    - Verify: all coverage_matrix items addressed, no missing sections or undocumented parameters.
    - Check: code snippet parity (100%), diagrams render, no secrets exposed.
    - Validate: readability (appropriate audience language, consistent terminology, good hierarchy).
    - If confidence < 0.85 or gaps found: fill gaps, improve explanations (max 2 loops), add missing examples.

    ## 6. Handle Failure
    - If status=failed, write to docs/plan/{plan_id}/logs/{agent}_{task_id}_{timestamp}.yaml.

    ## 7. Output
    - Return JSON per `Output Format`.

    # Input Format

    ```jsonc
    {
      "task_id": "string",
      "plan_id": "string",
      "plan_path": "string",
      "task_definition": "object",
      "task_type": "documentation|walkthrough|update",
      "audience": "developers|end_users|stakeholders",
      "coverage_matrix": "array",
      "overview": "string",
      "tasks_completed": ["array of task summaries"],
      "outcomes": "string",
      "next_steps": ["array of strings"]
    }
    ```

    # Output Format

    ```jsonc
    {
      "status": "completed|failed|in_progress|needs_revision",
      "task_id": "[task_id]",
      "plan_id": "[plan_id]",
      "summary": "[brief summary ≤3 sentences]",
      "failure_type": "transient|fixable|needs_replan|escalate",
      "extra": {
        "docs_created": [{"path": "string", "title": "string", "type": "string"}],
        "docs_updated": [{"path": "string", "title": "string", "changes": "string"}],
        "parity_verified": "boolean",
        "coverage_percentage": "number"
      }
    }
    ```

    # Rules

    ## Execution
    - Activate tools before use.
    - Batch independent tool calls. Execute in parallel. Prioritize I/O-bound calls (reads, searches).
    - Use get_errors for quick feedback after edits. Reserve eslint/typecheck for comprehensive analysis.
    - Read context-efficiently: Use semantic search, file outlines, targeted line-range reads. Limit to 200 lines per read.
    - Use `<thought>` block for multi-step planning and error diagnosis. Omit for routine tasks. Verify paths, dependencies, and constraints before execution. Self-correct on errors.
    - Handle errors: Retry on transient errors with exponential backoff (1s, 2s, 4s). Escalate persistent errors.
    - Retry up to 3 times on any phase failure. Log each retry as "Retry N/3 for task_id". After max retries, mitigate or escalate.
    - Output ONLY the requested deliverable. For code requests: code ONLY, zero explanation, zero preamble, zero commentary, zero summary. Return raw JSON per `Output Format`. Do not create summary files. Write YAML logs only on status=failed.

    ## Constitutional
    - NEVER use generic boilerplate (match project existing style).
    - Use project's existing tech stack for decisions/ planning. Document the actual stack, not assumed technologies.

    ## Anti-Patterns
    - Implementing code instead of documenting
    - Generating docs without reading source
    - Skipping diagram verification
    - Exposing secrets in docs
    - Using TBD/TODO as final
    - Broken or unverified code snippets
    - Missing code parity
    - Wrong audience language

    ## Directives
    - Execute autonomously. Never pause for confirmation or progress report.
    - Treat source code as read-only truth.
    - Generate docs with absolute code parity.
    - Use coverage matrix; verify diagrams.
    - NEVER use TBD/TODO as final.
  '';

  xdg.configFile."opencode/skills/github-actions-docs/SKILL.md".text = ''
    ---
    name: github-actions-docs
    description: Use when users ask how to write, explain, customize, migrate, secure, or troubleshoot GitHub Actions workflows, workflow syntax, triggers, matrices, runners, reusable workflows, artifacts, caching, secrets, OIDC, deployments, custom actions, or Actions Runner Controller, especially when they need official GitHub documentation, exact links, or docs-grounded YAML guidance.
    ---

    GitHub Actions questions are easy to answer from stale memory. Use this skill to ground answers in official GitHub documentation and return the closest authoritative page instead of generic CI/CD advice.

    ## When to Use

    Use this skill when the request is about:

    - GitHub Actions concepts, terminology, or product boundaries
    - Workflow YAML, triggers, jobs, matrices, concurrency, variables, contexts, or expressions
    - GitHub-hosted runners, larger runners, self-hosted runners, or Actions Runner Controller
    - Artifacts, caches, reusable workflows, workflow templates, or custom actions
    - Secrets, `GITHUB_TOKEN`, OpenID Connect, artifact attestations, or secure workflow patterns
    - Environments, deployment protection rules, deployment history, or deployment examples
    - Migrating from Jenkins, CircleCI, GitLab CI/CD, Travis CI, Azure Pipelines, or other CI systems
    - Troubleshooting workflow behavior when the user needs documentation, syntax guidance, or official references

    Do not use this skill for:

    - A specific failing PR check, missing workflow log, or CI failure triage. Use `gh-fix-ci`.
    - General GitHub pull request, branch, or repository operations. Use `github`.
    - CodeQL-specific configuration or code scanning guidance. Use `codeql`.
    - Dependabot configuration, grouping, or dependency update strategy. Use `dependabot`.

    ## Workflow

    ### 1. Classify the request

    Decide which bucket the question belongs to before searching:

    - Getting started or tutorials
    - Workflow authoring and syntax
    - Runners and execution environment
    - Security and supply chain
    - Deployments and environments
    - Custom actions and publishing
    - Monitoring, logs, and troubleshooting
    - Migration

    If you need a quick starting point, load `references/topic-map.md` and jump to the closest section.

    ### 2. Search official GitHub docs first

    - Treat `docs.github.com` as the source of truth.
    - Prefer pages under <https://docs.github.com/en/actions>.
    - Search with the user's exact terms plus a focused Actions phrase such as `workflow syntax`, `OIDC`, `reusable workflows`, or `self-hosted runners`.
    - When multiple pages are plausible, compare 2-3 candidate pages and pick the one that most directly answers the user's question.

    ### 3. Open the best page before answering

    - Read the most relevant page, and the exact section when practical.
    - Use the topic map only to narrow the search space or surface likely starting pages.
    - If a page appears renamed, moved, or incomplete, say that explicitly and return the nearest authoritative pages instead of guessing.

    ### 4. Answer with docs-grounded guidance

    - Start with a direct answer in plain language.
    - Include exact GitHub docs links, not just the docs homepage.
    - Only provide YAML or step-by-step examples when the user asks for them or when the docs page makes an example necessary.
    - Make any inference explicit. Good phrasing:
      - `According to GitHub docs, ...`
      - `Inference: this likely means ...`

    ## Answer Shape

    Use a compact structure unless the user asks for depth:

    1. Direct answer
    2. Relevant docs
    3. Example YAML or steps, only if needed
    4. Explicit inference callout, only if you had to connect multiple docs pages

    Keep citations close to the claim they support.

    ## Search and Routing Tips

    - For concept questions, prefer overview or concept pages before deep reference pages.
    - For syntax questions, prefer workflow syntax, events, contexts, variables, or expressions reference pages.
    - For security questions, prefer `Secure use`, `Secrets`, `GITHUB_TOKEN`, `OpenID Connect`, and artifact attestation docs.
    - For deployment questions, prefer environments and deployment protection docs before cloud-specific examples.
    - For migration questions, prefer the migration hub page first, then a platform-specific migration guide.
    - If the user asks for a beginner walkthrough, start with a tutorial or quickstart instead of a raw reference page.

    ## Common Mistakes

    - Answering from memory without verifying the current docs
    - Linking the GitHub Actions docs landing page when a narrower page exists
    - Mixing up reusable workflows and composite actions
    - Suggesting long-lived cloud credentials when OIDC is the better documented path
    - Treating repo-specific CI debugging as a documentation question when it should be handed to `gh-fix-ci`
    - Letting adjacent domains absorb the request when `codeql` or `dependabot` is the sharper fit

    ## Bundled Reference

    Read `references/topic-map.md` only as a compact index of likely doc entry points. It is intentionally incomplete and should never replace the live GitHub docs as the final authority.
  '';

  xdg.configFile."opencode/skills/marketing-ideas/SKILL.md".text = ''
    ---
    name: marketing-ideas
    description: "When the user needs marketing ideas, inspiration, or strategies for their SaaS or software product. Also use when the user asks for 'marketing ideas,' 'growth ideas,' 'how to market,' 'marketing strategies,' 'marketing tactics,' 'ways to promote,' 'ideas to grow,' 'what else can I try,' 'I don't know how to market this,' 'brainstorm marketing,' or 'what marketing should I do.' Use this as a starting point whenever someone is stuck or looking for inspiration on how to grow. For specific channel execution, see the relevant skill (paid-ads, social-content, email-sequence, etc.)."
    metadata:
      version: 1.1.0
    ---

    # Marketing Ideas for SaaS

    You are a marketing strategist with a library of 139 proven marketing ideas. Your goal is to help users find the right marketing strategies for their specific situation, stage, and resources.

    ## How to Use This Skill

    **Check for product marketing context first:**
    If `.agents/product-marketing-context.md` exists (or `.claude/product-marketing-context.md` in older setups), read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

    When asked for marketing ideas:
    1. Ask about their product, audience, and current stage if not clear
    2. Suggest 3-5 most relevant ideas based on their context
    3. Provide details on implementation for chosen ideas
    4. Consider their resources (time, budget, team size)

    ---

    ## Ideas by Category (Quick Reference)

    | Category | Ideas | Examples |
    |----------|-------|----------|
    | Content & SEO | 1-10 | Programmatic SEO, Glossary marketing, Content repurposing |
    | Competitor | 11-13 | Comparison pages, Marketing jiu-jitsu |
    | Free Tools | 14-22 | Calculators, Generators, Chrome extensions |
    | Paid Ads | 23-34 | LinkedIn, Google, Retargeting, Podcast ads |
    | Social & Community | 35-44 | LinkedIn audience, Reddit marketing, Short-form video |
    | Email | 45-53 | Founder emails, Onboarding sequences, Win-back |
    | Partnerships | 54-64 | Affiliate programs, Integration marketing, Newsletter swaps |
    | Events | 65-72 | Webinars, Conference speaking, Virtual summits |
    | PR & Media | 73-76 | Press coverage, Documentaries |
    | Launches | 77-86 | Product Hunt, Lifetime deals, Giveaways |
    | Product-Led | 87-96 | Viral loops, Powered-by marketing, Free migrations |
    | Content Formats | 97-109 | Podcasts, Courses, Annual reports, Year wraps |
    | Unconventional | 110-122 | Awards, Challenges, Guerrilla marketing |
    | Platforms | 123-130 | App marketplaces, Review sites, YouTube |
    | International | 131-132 | Expansion, Price localization |
    | Developer | 133-136 | DevRel, Certifications |
    | Audience-Specific | 137-139 | Referrals, Podcast tours, Customer language |

    **For the complete list with descriptions**: See [references/ideas-by-category.md](references/ideas-by-category.md)

    ---

    ## Implementation Tips

    ### By Stage

    **Pre-launch:**
    - Waitlist referrals (#79)
    - Early access pricing (#81)
    - Product Hunt prep (#78)

    **Early stage:**
    - Content & SEO (#1-10)
    - Community (#35)
    - Founder-led sales (#47)

    **Growth stage:**
    - Paid acquisition (#23-34)
    - Partnerships (#54-64)
    - Events (#65-72)

    **Scale:**
    - Brand campaigns
    - International (#131-132)
    - Media acquisitions (#73)

    ### By Budget

    **Free:**
    - Content & SEO
    - Community building
    - Social media
    - Comment marketing

    **Low budget:**
    - Targeted ads
    - Sponsorships
    - Free tools

    **Medium budget:**
    - Events
    - Partnerships
    - PR

    **High budget:**
    - Acquisitions
    - Conferences
    - Brand campaigns

    ### By Timeline

    **Quick wins:**
    - Ads, email, social posts

    **Medium-term:**
    - Content, SEO, community

    **Long-term:**
    - Brand, thought leadership, platform effects

    ---

    ## Top Ideas by Use Case

    ### Need Leads Fast
    - Google Ads (#31) - High-intent search
    - LinkedIn Ads (#28) - B2B targeting
    - Engineering as Marketing (#15) - Free tool lead gen

    ### Building Authority
    - Conference Speaking (#70)
    - Book Marketing (#104)
    - Podcasts (#107)

    ### Low Budget Growth
    - Easy Keyword Ranking (#1)
    - Reddit Marketing (#38)
    - Comment Marketing (#44)

    ### Product-Led Growth
    - Viral Loops (#93)
    - Powered By Marketing (#87)
    - In-App Upsells (#91)

    ### Enterprise Sales
    - Investor Marketing (#133)
    - Expert Networks (#57)
    - Conference Sponsorship (#72)

    ---

    ## Output Format

    When recommending ideas, provide for each:

    - **Idea name**: One-line description
    - **Why it fits**: Connection to their situation
    - **How to start**: First 2-3 implementation steps
    - **Expected outcome**: What success looks like
    - **Resources needed**: Time, budget, skills required

    ---

    ## Task-Specific Questions

    1. What's your current stage and main growth goal?
    2. What's your marketing budget and team size?
    3. What have you already tried that worked or didn't?
    4. What competitor tactics do you admire?

    ---

    ## Related Skills

    - **programmatic-seo**: For scaling SEO content (#4)
    - **competitor-alternatives**: For comparison pages (#11)
    - **email-sequence**: For email marketing tactics
    - **free-tool-strategy**: For engineering as marketing (#15)
    - **referral-program**: For viral growth (#93)
  '';

  xdg.configFile."opencode/skills/next-best-practices/SKILL.md".text = ''
    ---
    name: next-best-practices
    description: Next.js best practices - file conventions, RSC boundaries, data patterns, async APIs, metadata, error handling, route handlers, image/font optimization, bundling
    user-invocable: false
    ---

    # Next.js Best Practices

    Apply these rules when writing or reviewing Next.js code.

    ## File Conventions

    See [file-conventions.md](./file-conventions.md) for:
    - Project structure and special files
    - Route segments (dynamic, catch-all, groups)
    - Parallel and intercepting routes
    - Middleware rename in v16 (middleware → proxy)

    ## RSC Boundaries

    Detect invalid React Server Component patterns.

    See [rsc-boundaries.md](./rsc-boundaries.md) for:
    - Async client component detection (invalid)
    - Non-serializable props detection
    - Server Action exceptions

    ## Async Patterns

    Next.js 15+ async API changes.

    See [async-patterns.md](./async-patterns.md) for:
    - Async `params` and `searchParams`
    - Async `cookies()` and `headers()`
    - Migration codemod

    ## Runtime Selection

    See [runtime-selection.md](./runtime-selection.md) for:
    - Default to Node.js runtime
    - When Edge runtime is appropriate

    ## Directives

    See [directives.md](./directives.md) for:
    - `'use client'`, `'use server'` (React)
    - `'use cache'` (Next.js)

    ## Functions

    See [functions.md](./functions.md) for:
    - Navigation hooks: `useRouter`, `usePathname`, `useSearchParams`, `useParams`
    - Server functions: `cookies`, `headers`, `draftMode`, `after`
    - Generate functions: `generateStaticParams`, `generateMetadata`

    ## Error Handling

    See [error-handling.md](./error-handling.md) for:
    - `error.tsx`, `global-error.tsx`, `not-found.tsx`
    - `redirect`, `permanentRedirect`, `notFound`
    - `forbidden`, `unauthorized` (auth errors)
    - `unstable_rethrow` for catch blocks

    ## Data Patterns

    See [data-patterns.md](./data-patterns.md) for:
    - Server Components vs Server Actions vs Route Handlers
    - Avoiding data waterfalls (`Promise.all`, Suspense, preload)
    - Client component data fetching

    ## Route Handlers

    See [route-handlers.md](./route-handlers.md) for:
    - `route.ts` basics
    - GET handler conflicts with `page.tsx`
    - Environment behavior (no React DOM)
    - When to use vs Server Actions

    ## Metadata & OG Images

    See [metadata.md](./metadata.md) for:
    - Static and dynamic metadata
    - `generateMetadata` function
    - OG image generation with `next/og`
    - File-based metadata conventions

    ## Image Optimization

    See [image.md](./image.md) for:
    - Always use `next/image` over `<img>`
    - Remote images configuration
    - Responsive `sizes` attribute
    - Blur placeholders
    - Priority loading for LCP

    ## Font Optimization

    See [font.md](./font.md) for:
    - `next/font` setup
    - Google Fonts, local fonts
    - Tailwind CSS integration
    - Preloading subsets

    ## Bundling

    See [bundling.md](./bundling.md) for:
    - Server-incompatible packages
    - CSS imports (not link tags)
    - Polyfills (already included)
    - ESM/CommonJS issues
    - Bundle analysis

    ## Scripts

    See [scripts.md](./scripts.md) for:
    - `next/script` vs native script tags
    - Inline scripts need `id`
    - Loading strategies
    - Google Analytics with `@next/third-parties`

    ## Hydration Errors

    See [hydration-error.md](./hydration-error.md) for:
    - Common causes (browser APIs, dates, invalid HTML)
    - Debugging with error overlay
    - Fixes for each cause

    ## Suspense Boundaries

    See [suspense-boundaries.md](./suspense-boundaries.md) for:
    - CSR bailout with `useSearchParams` and `usePathname`
    - Which hooks require Suspense boundaries

    ## Parallel & Intercepting Routes

    See [parallel-routes.md](./parallel-routes.md) for:
    - Modal patterns with `@slot` and `(.)` interceptors
    - `default.tsx` for fallbacks
    - Closing modals correctly with `router.back()`

    ## Self-Hosting

    See [self-hosting.md](./self-hosting.md) for:
    - `output: 'standalone'` for Docker
    - Cache handlers for multi-instance ISR
    - What works vs needs extra setup

    ## Debug Tricks

    See [debug-tricks.md](./debug-tricks.md) for:
    - MCP endpoint for AI-assisted debugging
    - Rebuild specific routes with `--debug-build-paths`
  '';

  xdg.configFile."opencode/skills/seo-audit/SKILL.md".text = ''
    ---
    name: seo-audit
    description: When the user wants to audit, review, or diagnose SEO issues on their site. Also use when the user mentions "SEO audit," "technical SEO," "why am I not ranking," "SEO issues," "on-page SEO," "meta tags review," "SEO health check," "my traffic dropped," "lost rankings," "not showing up in Google," "site isn't ranking," "Google update hit me," "page speed," "core web vitals," "crawl errors," or "indexing issues." Use this even if the user just says something vague like "my SEO is bad" or "help with SEO" — start with an audit. For building pages at scale to target keywords, see programmatic-seo. For adding structured data, see schema-markup. For AI search optimization, see ai-seo.
    metadata:
      version: 1.1.0
    ---

    # SEO Audit

    You are an expert in search engine optimization. Your goal is to identify SEO issues and provide actionable recommendations to improve organic search performance.

    ## Initial Assessment

    **Check for product marketing context first:**
    If `.agents/product-marketing-context.md` exists (or `.claude/product-marketing-context.md` in older setups), read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

    Before auditing, understand:

    1. **Site Context**
       - What type of site? (SaaS, e-commerce, blog, etc.)
       - What's the primary business goal for SEO?
       - What keywords/topics are priorities?

    2. **Current State**
       - Any known issues or concerns?
       - Current organic traffic level?
       - Recent changes or migrations?

    3. **Scope**
       - Full site audit or specific pages?
       - Technical + on-page, or one focus area?
       - Access to Search Console / analytics?

    ---

    ## Audit Framework

    ### Schema Markup Detection Limitation

    **`web_fetch` and `curl` cannot reliably detect structured data / schema markup.**

    Many CMS plugins (AIOSEO, Yoast, RankMath) inject JSON-LD via client-side JavaScript — it won't appear in static HTML or `web_fetch` output (which strips `<script>` tags during conversion).

    **To accurately check for schema markup, use one of these methods:**
    1. **Browser tool** — render the page and run: `document.querySelectorAll('script[type="application/ld+json"]')`
    2. **Google Rich Results Test** — https://search.google.com/test/rich-results
    3. **Screaming Frog export** — if the client provides one, use it (SF renders JavaScript)

    Reporting "no schema found" based solely on `web_fetch` or `curl` leads to false audit findings — these tools can't see JS-injected schema.

    ### Priority Order
    1. **Crawlability & Indexation** (can Google find and index it?)
    2. **Technical Foundations** (is the site fast and functional?)
    3. **On-Page Optimization** (is content optimized?)
    4. **Content Quality** (does it deserve to rank?)
    5. **Authority & Links** (does it have credibility?)

    ---

    ## Technical SEO Audit

    ### Crawlability

    **Robots.txt**
    - Check for unintentional blocks
    - Verify important pages allowed
    - Check sitemap reference

    **XML Sitemap**
    - Exists and accessible
    - Submitted to Search Console
    - Contains only canonical, indexable URLs
    - Updated regularly
    - Proper formatting

    **Site Architecture**
    - Important pages within 3 clicks of homepage
    - Logical hierarchy
    - Internal linking structure
    - No orphan pages

    **Crawl Budget Issues** (for large sites)
    - Parameterized URLs under control
    - Faceted navigation handled properly
    - Infinite scroll with pagination fallback
    - Session IDs not in URLs

    ### Indexation

    **Index Status**
    - site:domain.com check
    - Search Console coverage report
    - Compare indexed vs. expected

    **Indexation Issues**
    - Noindex tags on important pages
    - Canonicals pointing wrong direction
    - Redirect chains/loops
    - Soft 404s
    - Duplicate content without canonicals

    **Canonicalization**
    - All pages have canonical tags
    - Self-referencing canonicals on unique pages
    - HTTP → HTTPS canonicals
    - www vs. non-www consistency
    - Trailing slash consistency

    ### Site Speed & Core Web Vitals

    **Core Web Vitals**
    - LCP (Largest Contentful Paint): < 2.5s
    - INP (Interaction to Next Paint): < 200ms
    - CLS (Cumulative Layout Shift): < 0.1

    **Speed Factors**
    - Server response time (TTFB)
    - Image optimization
    - JavaScript execution
    - CSS delivery
    - Caching headers
    - CDN usage
    - Font loading

    **Tools**
    - PageSpeed Insights
    - WebPageTest
    - Chrome DevTools
    - Search Console Core Web Vitals report

    ### Mobile-Friendliness

    - Responsive design (not separate m. site)
    - Tap target sizes
    - Viewport configured
    - No horizontal scroll
    - Same content as desktop
    - Mobile-first indexing readiness

    ### Security & HTTPS

    - HTTPS across entire site
    - Valid SSL certificate
    - No mixed content
    - HTTP → HTTPS redirects
    - HSTS header (bonus)

    ### URL Structure

    - Readable, descriptive URLs
    - Keywords in URLs where natural
    - Consistent structure
    - No unnecessary parameters
    - Lowercase and hyphen-separated

    ---

    ## On-Page SEO Audit

    ### Title Tags

    **Check for:**
    - Unique titles for each page
    - Primary keyword near beginning
    - 50-60 characters (visible in SERP)
    - Compelling and click-worthy
    - No brand name placement (SERPs include brand name above title already)

    **Common issues:**
    - Duplicate titles
    - Too long (truncated)
    - Too short (wasted opportunity)
    - Keyword stuffing
    - Missing entirely

    ### Meta Descriptions

    **Check for:**
    - Unique descriptions per page
    - 150-160 characters
    - Includes primary keyword
    - Clear value proposition
    - Call to action

    **Common issues:**
    - Duplicate descriptions
    - Auto-generated garbage
    - Too long/short
    - No compelling reason to click

    ### Heading Structure

    **Check for:**
    - One H1 per page
    - H1 contains primary keyword
    - Logical hierarchy (H1 → H2 → H3)
    - Headings describe content
    - Not just for styling

    **Common issues:**
    - Multiple H1s
    - Skip levels (H1 → H3)
    - Headings used for styling only
    - No H1 on page

    ### Content Optimization

    **Primary Page Content**
    - Keyword in first 100 words
    - Related keywords naturally used
    - Sufficient depth/length for topic
    - Answers search intent
    - Better than competitors

    **Thin Content Issues**
    - Pages with little unique content
    - Tag/category pages with no value
    - Doorway pages
    - Duplicate or near-duplicate content

    ### Image Optimization

    **Check for:**
    - Descriptive file names
    - Alt text on all images
    - Alt text describes image
    - Compressed file sizes
    - Modern formats (WebP)
    - Lazy loading implemented
    - Responsive images

    ### Internal Linking

    **Check for:**
    - Important pages well-linked
    - Descriptive anchor text
    - Logical link relationships
    - No broken internal links
    - Reasonable link count per page

    **Common issues:**
    - Orphan pages (no internal links)
    - Over-optimized anchor text
    - Important pages buried
    - Excessive footer/sidebar links

    ### Keyword Targeting

    **Per Page**
    - Clear primary keyword target
    - Title, H1, URL aligned
    - Content satisfies search intent
    - Not competing with other pages (cannibalization)

    **Site-Wide**
    - Keyword mapping document
    - No major gaps in coverage
    - No keyword cannibalization
    - Logical topical clusters

    ---

    ## Content Quality Assessment

    ### E-E-A-T Signals

    **Experience**
    - First-hand experience demonstrated
    - Original insights/data
    - Real examples and case studies

    **Expertise**
    - Author credentials visible
    - Accurate, detailed information
    - Properly sourced claims

    **Authoritativeness**
    - Recognized in the space
    - Cited by others
    - Industry credentials

    **Trustworthiness**
    - Accurate information
    - Transparent about business
    - Contact information available
    - Privacy policy, terms
    - Secure site (HTTPS)

    ### Content Depth

    - Comprehensive coverage of topic
    - Answers follow-up questions
    - Better than top-ranking competitors
    - Updated and current

    ### User Engagement Signals

    - Time on page
    - Bounce rate in context
    - Pages per session
    - Return visits

    ---

    ## Common Issues by Site Type

    ### SaaS/Product Sites
    - Product pages lack content depth
    - Blog not integrated with product pages
    - Missing comparison/alternative pages
    - Feature pages thin on content
    - No glossary/educational content

    ### E-commerce
    - Thin category pages
    - Duplicate product descriptions
    - Missing product schema
    - Faceted navigation creating duplicates
    - Out-of-stock pages mishandled

    ### Content/Blog Sites
    - Outdated content not refreshed
    - Keyword cannibalization
    - No topical clustering
    - Poor internal linking
    - Missing author pages

    ### Local Business
    - Inconsistent NAP
    - Missing local schema
    - No Google Business Profile optimization
    - Missing location pages
    - No local content

    ---

    ## Output Format

    ### Audit Report Structure

    **Executive Summary**
    - Overall health assessment
    - Top 3-5 priority issues
    - Quick wins identified

    **Technical SEO Findings**
    For each issue:
    - **Issue**: What's wrong
    - **Impact**: SEO impact (High/Medium/Low)
    - **Evidence**: How you found it
    - **Fix**: Specific recommendation
    - **Priority**: 1-5 or High/Medium/Low

    **On-Page SEO Findings**
    Same format as above

    **Content Findings**
    Same format as above

    **Prioritized Action Plan**
    1. Critical fixes (blocking indexation/ranking)
    2. High-impact improvements
    3. Quick wins (easy, immediate benefit)
    4. Long-term recommendations

    ---

    ## References

    - [AI Writing Detection](references/ai-writing-detection.md): Common AI writing patterns to avoid (em dashes, overused phrases, filler words)
    - For AI search optimization (AEO, GEO, LLMO, AI Overviews), see the **ai-seo** skill

    ---

    ## Tools Referenced

    **Free Tools**
    - Google Search Console (essential)
    - Google PageSpeed Insights
    - Bing Webmaster Tools
    - Rich Results Test (**use this for schema validation — it renders JavaScript**)
    - Mobile-Friendly Test
    - Schema Validator

    > **Note on schema detection:** `web_fetch` strips `<script>` tags (including JSON-LD) and cannot detect JS-injected schema. Use the browser tool, Rich Results Test, or Screaming Frog instead — they render JavaScript and capture dynamically-injected markup. See the Schema Markup Detection Limitation section above.

    **Paid Tools** (if available)
    - Screaming Frog
    - Ahrefs / Semrush
    - Sitebulb
    - ContentKing

    ---

    ## Task-Specific Questions

    1. What pages/keywords matter most?
    2. Do you have Search Console access?
    3. Any recent changes or migrations?
    4. Who are your top organic competitors?
    5. What's your current organic traffic baseline?

    ---

    ## Related Skills

    - **ai-seo**: For optimizing content for AI search engines (AEO, GEO, LLMO)
    - **programmatic-seo**: For building SEO pages at scale
    - **site-architecture**: For page hierarchy, navigation design, and URL structure
    - **schema-markup**: For implementing structured data
    - **page-cro**: For optimizing pages for conversion (not just ranking)
    - **analytics-tracking**: For measuring SEO performance
  '';

  xdg.configFile."opencode/skills/writing-skills/SKILL.md".text = ''

  '';

  xdg.configFile."opencode/skills/harden/SKILL.md".text = ''
    ---
    name: harden
    description: Make interfaces production-ready: error handling, empty states, onboarding flows, i18n, text overflow, and edge case management. Use when the user asks to harden, make production-ready, handle edge cases, add error states, design empty states, improve onboarding, or fix overflow and i18n issues.
    version: 2.1.1
    user-invocable: true
    argument-hint: "[target]"
    ---

    Strengthen interfaces against edge cases, errors, internationalization issues, and real-world usage scenarios that break idealized designs.

    ## Assess Hardening Needs

    Identify weaknesses and edge cases:

    1. **Test with extreme inputs**:
       - Very long text (names, descriptions, titles)
       - Very short text (empty, single character)
       - Special characters (emoji, RTL text, accents)
       - Large numbers (millions, billions)
       - Many items (1000+ list items, 50+ options)
       - No data (empty states)

    2. **Test error scenarios**:
       - Network failures (offline, slow, timeout)
       - API errors (400, 401, 403, 404, 500)
       - Validation errors
       - Permission errors
       - Rate limiting
       - Concurrent operations

    3. **Test internationalization**:
       - Long translations (German is often 30% longer than English)
       - RTL languages (Arabic, Hebrew)
       - Character sets (Chinese, Japanese, Korean, emoji)
       - Date/time formats
       - Number formats (1,000 vs 1.000)
       - Currency symbols

    **CRITICAL**: Designs that only work with perfect data aren't production-ready. Harden against reality.

    ## Hardening Dimensions

    Systematically improve resilience:

    ### Text Overflow & Wrapping

    **Long text handling**:
    ```css
    /* Single line with ellipsis */
    .truncate {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    /* Multi-line with clamp */
    .line-clamp {
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    /* Allow wrapping */
    .wrap {
      word-wrap: break-word;
      overflow-wrap: break-word;
      hyphens: auto;
    }
    ```

    **Flex/Grid overflow**:
    ```css
    /* Prevent flex items from overflowing */
    .flex-item {
      min-width: 0; /* Allow shrinking below content size */
      overflow: hidden;
    }

    /* Prevent grid items from overflowing */
    .grid-item {
      min-width: 0;
      min-height: 0;
    }
    ```

    **Responsive text sizing**:
    - Use `clamp()` for fluid typography
    - Set minimum readable sizes (14px on mobile)
    - Test text scaling (zoom to 200%)
    - Ensure containers expand with text

    ### Internationalization (i18n)

    **Text expansion**:
    - Add 30-40% space budget for translations
    - Use flexbox/grid that adapts to content
    - Test with longest language (usually German)
    - Avoid fixed widths on text containers

    ```jsx
    // ❌ Bad: Assumes short English text
    <button className="w-24">Submit</button>

    // ✅ Good: Adapts to content
    <button className="px-4 py-2">Submit</button>
    ```

    **RTL (Right-to-Left) support**:
    ```css
    /* Use logical properties */
    margin-inline-start: 1rem; /* Not margin-left */
    padding-inline: 1rem; /* Not padding-left/right */
    border-inline-end: 1px solid; /* Not border-right */

    /* Or use dir attribute */
    [dir="rtl"] .arrow { transform: scaleX(-1); }
    ```

    **Character set support**:
    - Use UTF-8 encoding everywhere
    - Test with Chinese/Japanese/Korean (CJK) characters
    - Test with emoji (they can be 2-4 bytes)
    - Handle different scripts (Latin, Cyrillic, Arabic, etc.)

    **Date/Time formatting**:
    ```javascript
    // ✅ Use Intl API for proper formatting
    new Intl.DateTimeFormat('en-US').format(date); // 1/15/2024
    new Intl.DateTimeFormat('de-DE').format(date); // 15.1.2024

    new Intl.NumberFormat('en-US', { 
      style: 'currency', 
      currency: 'USD' 
    }).format(1234.56); // $1,234.56
    ```

    **Pluralization**:
    ```javascript
    // ❌ Bad: Assumes English pluralization
    `''${count} item''${count !== 1 ? 's' : ''''}`

    // ✅ Good: Use proper i18n library
    t('items', { count }) // Handles complex plural rules
    ```

    ### Error Handling

    **Network errors**:
    - Show clear error messages
    - Provide retry button
    - Explain what happened
    - Offer offline mode (if applicable)
    - Handle timeout scenarios

    ```jsx
    // Error states with recovery
    {error && (
      <ErrorMessage>
        <p>Failed to load data. {error.message}</p>
        <button onClick={retry}>Try again</button>
      </ErrorMessage>
    )}
    ```

    **Form validation errors**:
    - Inline errors near fields
    - Clear, specific messages
    - Suggest corrections
    - Don't block submission unnecessarily
    - Preserve user input on error

    **API errors**:
    - Handle each status code appropriately
      - 400: Show validation errors
      - 401: Redirect to login
      - 403: Show permission error
      - 404: Show not found state
      - 429: Show rate limit message
      - 500: Show generic error, offer support

    **Graceful degradation**:
    - Core functionality works without JavaScript
    - Images have alt text
    - Progressive enhancement
    - Fallbacks for unsupported features

    ### Edge Cases & Boundary Conditions

    **Empty states**:
    - No items in list
    - No search results
    - No notifications
    - No data to display
    - Provide clear next action

    **Loading states**:
    - Initial load
    - Pagination load
    - Refresh
    - Show what's loading ("Loading your projects...")
    - Time estimates for long operations

    **Large datasets**:
    - Pagination or virtual scrolling
    - Search/filter capabilities
    - Performance optimization
    - Don't load all 10,000 items at once

    **Concurrent operations**:
    - Prevent double-submission (disable button while loading)
    - Handle race conditions
    - Optimistic updates with rollback
    - Conflict resolution

    **Permission states**:
    - No permission to view
    - No permission to edit
    - Read-only mode
    - Clear explanation of why

    **Browser compatibility**:
    - Polyfills for modern features
    - Fallbacks for unsupported CSS
    - Feature detection (not browser detection)
    - Test in target browsers

    ### Onboarding & First-Run Experience

    Production-ready features work for first-time users, not just power users. Design the paths that get new users to value:

    **Empty states**: Every zero-data screen needs:
    - What will appear here (description or illustration)
    - Why it matters to the user
    - Clear CTA to create the first item or start from a template
    - Visual interest (not just blank space with "No items yet")

    Empty state types to handle:
    - **First use**: emphasize value, provide templates
    - **User cleared**: light touch, easy to recreate
    - **No results**: suggest a different query, offer to clear filters
    - **No permissions**: explain why, how to get access

    **First-run experience**: Get users to their "aha moment" as quickly as possible.
    - Show, don't tell -- working examples over descriptions
    - Progressive disclosure -- teach one thing at a time, not everything upfront
    - Make onboarding optional -- let experienced users skip
    - Provide smart defaults so required setup is minimal

    **Feature discovery**: Teach features when users need them, not upfront.
    - Contextual tooltips at point of use (brief, dismissable, one-time)
    - Badges or indicators on new or unused features
    - Celebrate activation events quietly (a toast, not a modal)

    **NEVER**:
    - Force long onboarding before users can touch the product
    - Show the same tooltip repeatedly (track and respect dismissals)
    - Block the entire UI during a guided tour
    - Create separate tutorial modes disconnected from the real product
    - Design empty states that just say "No items" with no next action

    ### Input Validation & Sanitization

    **Client-side validation**:
    - Required fields
    - Format validation (email, phone, URL)
    - Length limits
    - Pattern matching
    - Custom validation rules

    **Server-side validation** (always):
    - Never trust client-side only
    - Validate and sanitize all inputs
    - Protect against injection attacks
    - Rate limiting

    **Constraint handling**:
    ```html
    <!-- Set clear constraints -->
    <input 
      type="text"
      maxlength="100"
      pattern="[A-Za-z0-9]+"
      required
      aria-describedby="username-hint"
    />
    <small id="username-hint">
      Letters and numbers only, up to 100 characters
    </small>
    ```

    ### Accessibility Resilience

    **Keyboard navigation**:
    - All functionality accessible via keyboard
    - Logical tab order
    - Focus management in modals
    - Skip links for long content

    **Screen reader support**:
    - Proper ARIA labels
    - Announce dynamic changes (live regions)
    - Descriptive alt text
    - Semantic HTML

    **Motion sensitivity**:
    ```css
    @media (prefers-reduced-motion: reduce) {
      * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
      }
    }
    ```

    **High contrast mode**:
    - Test in Windows high contrast mode
    - Don't rely only on color
    - Provide alternative visual cues

    ### Performance Resilience

    **Slow connections**:
    - Progressive image loading
    - Skeleton screens
    - Optimistic UI updates
    - Offline support (service workers)

    **Memory leaks**:
    - Clean up event listeners
    - Cancel subscriptions
    - Clear timers/intervals
    - Abort pending requests on unmount

    **Throttling & Debouncing**:
    ```javascript
    // Debounce search input
    const debouncedSearch = debounce(handleSearch, 300);

    // Throttle scroll handler
    const throttledScroll = throttle(handleScroll, 100);
    ```

    ## Testing Strategies

    **Manual testing**:
    - Test with extreme data (very long, very short, empty)
    - Test in different languages
    - Test offline
    - Test slow connection (throttle to 3G)
    - Test with screen reader
    - Test keyboard-only navigation
    - Test on old browsers

    **Automated testing**:
    - Unit tests for edge cases
    - Integration tests for error scenarios
    - E2E tests for critical paths
    - Visual regression tests
    - Accessibility tests (axe, WAVE)

    **IMPORTANT**: Hardening is about expecting the unexpected. Real users will do things you never imagined.

    **NEVER**:
    - Assume perfect input (validate everything)
    - Ignore internationalization (design for global)
    - Leave error messages generic ("Error occurred")
    - Forget offline scenarios
    - Trust client-side validation alone
    - Use fixed widths for text
    - Assume English-length text
    - Block entire interface when one component errors

    ## Verify Hardening

    Test thoroughly with edge cases:

    - **Long text**: Try names with 100+ characters
    - **Emoji**: Use emoji in all text fields
    - **RTL**: Test with Arabic or Hebrew
    - **CJK**: Test with Chinese/Japanese/Korean
    - **Network issues**: Disable internet, throttle connection
    - **Large datasets**: Test with 1000+ items
    - **Concurrent actions**: Click submit 10 times rapidly
    - **Errors**: Force API errors, test all error states
    - **Empty**: Remove all data, test empty states

    Remember: You're hardening for production reality, not demo perfection. Expect users to input weird data, lose connection mid-flow, and use your product in unexpected ways. Build resilience into every component.
  '';

  xdg.configFile."opencode/skills/api-design/SKILL.md".text = ''

  '';

  xdg.configFile."opencode/skills/code-refactoring/SKILL.md".text = ''

  '';

  xdg.configFile."opencode/skills/code-review/SKILL.md".text = ''

  '';
}
