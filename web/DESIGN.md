# Calm Horizon — OpportunityLens visual direction

Premium, iOS-inspired **web** UI (not a native iOS app).

### Intent

- **Mood:** calm, capable, optimistic.
- **One dominant material:** solid, readable off-white content sheets.
- **Glass accent:** desktop rail, sticky top bar and a floating mobile tab dock.
- **Clay-like accent:** tactile CTA buttons, progress symbols, simple icon tiles.
- **Brand color:** restrained lavender (#5765cb), with muted mint for success.
- **Type:** Apple system font stack with cross-platform system fallback;
  no licensed Apple fonts or Google Fonts downloads.
- **Motion:** subtle hover and press feedback only; reduced-motion fallback.
- **Content:** no invented metrics, scholarships, testimonials, or AI promises.

### Behavior and functional preservation

Only appearance, dashboard microcopy and navigation semantics changed.
The existing React routes, AI analyzer, manual rules, Supabase Auth/session
management, profile persistence, real opportunities and bookmarks remain
in the same source code. The original Python Streamlit app and FastAPI
backend are untouched.

On narrow screens the four most frequent destinations (Home, Discover,
Analyze and Profile) are in a bottom dock. Checklist, Settings and Account
remain available in the hamburger panel. Both navigation systems have
screen-reader labels, focus-visible and active-page indicators.

### Layout and QA

Test on narrow phones (320px/375px), tablets (768px), small laptops
(1024px) and wide desktop (1440px). Inspect default, empty, error and
signed-in/guest screens, form labels, keyboard access, large fonts,
reduced motion and reduced transparency. CSS falls back to opaque navigation
when \`backdrop-filter\` is unsupported.

\`web/src/premium.css\` holds semantic tokens and all art-direction
overrides, leaving the existing component layout/styles intact for
faster iteration. Do not add heavy canvas/WebGL for this design.

### References

- https://developer.apple.com/design/human-interface-guidelines/materials
- https://developer.apple.com/videos/play/wwdc2026/251/
- https://github.com/RitvikChunamari/rcs-frontend-skill
- https://github.com/RitvikChunamari/rcs-frontend-skill/blob/main/references/frontend-engineering.md
- https://github.com/RitvikChunamari/rcs-frontend-skill/blob/main/references/style-composition.md
