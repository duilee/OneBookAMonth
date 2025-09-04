# OneBookAMonth Agent Handoff Guide

## 🤝 Agent Collaboration Workflow

### Overview
This guide defines how agents collaborate on OneBookAMonth features, ensuring smooth handoffs and consistent quality.

---

## 📋 Standard Feature Development Flow

### 1. Product Vision (product-owner)
**Triggers**: New feature request, user feedback, market opportunity

**Responsibilities**:
- Define the reading problem to solve
- Set ambitious but achievable goals
- Create initial PRD with vision
- Determine success metrics

**Outputs**:
- Feature PRD (using reading-feature-prd.md template)
- Success criteria
- Priority ranking

**Handoff to**: market-researcher

---

### 2. Market Validation (market-researcher)
**Receives**: Feature vision and initial PRD

**Responsibilities**:
- Validate reading market opportunity
- Analyze competitor features (Goodreads, Bookly, etc.)
- Quantify user demand
- Calculate market size

**Outputs**:
- Completed Market Analysis section in PRD
- GO/NO-GO recommendation
- User research insights
- Competitive positioning

**Handoff to**: tech-lead (if GO), product-owner (if NO-GO for pivot)

---

### 3. Technical Architecture (tech-lead)
**Receives**: Validated PRD with market data

**Responsibilities**:
- Design SwiftData models
- Plan SwiftUI architecture
- Identify technical risks
- Estimate development effort

**Outputs**:
- Technical Architecture section in PRD
- Data model specifications
- Performance requirements
- Risk mitigation plan

**Handoff to**: designer

---

### 4. Design System (designer)
**Receives**: PRD with technical constraints

**Responsibilities**:
- Create UI mockups following iOS HIG
- Design reading-focused interactions
- Ensure visual progress representation
- Maintain design system consistency

**Outputs**:
- Design Requirements section in PRD
- Component specifications
- Interaction patterns
- Visual assets

**Handoff to**: ios-developer

---

### 5. Implementation (ios-developer)
**Receives**: Complete PRD with all sections

**Responsibilities**:
- Implement SwiftUI views
- Create ViewModels with @Observable
- Integrate with SwiftData
- Add HorizonCalendar features if needed

**Outputs**:
- Feature implementation
- Unit tests
- Preview providers
- Documentation

**Handoff to**: localization-expert (if UI text), product-owner (for review)

---

### 6. Localization (localization-expert)
**Receives**: Implemented features with UI text

**Responsibilities**:
- Add LocalizedStringResource entries
- Update Localizable.xcstrings
- Ensure reading terms are properly localized
- Test with different locales

**Outputs**:
- Localized strings
- Translation notes
- Pluralization rules
- RTL support verification

**Handoff to**: product-owner (final review)

---

## 🔄 Quick Fix Workflow

For bugs and minor improvements:

1. **ios-developer**: Identifies issue → implements fix
2. **designer**: Reviews if UI affected
3. **tech-lead**: Reviews if architecture impacted
4. **product-owner**: Approves for release

---

## 📝 Handoff Checklist

### Before Passing Work:
- [ ] PRD section completed
- [ ] Key decisions documented
- [ ] Blockers identified
- [ ] Questions for next agent listed
- [ ] Context added to project-context.md if needed

### When Receiving Work:
- [ ] Review previous sections
- [ ] Understand constraints
- [ ] Ask clarifying questions
- [ ] Confirm understanding before proceeding

---

## 💬 Communication Patterns

### Information to Always Include:
1. **What changed**: Specific updates made
2. **Why**: Rationale for decisions
3. **Impact**: How this affects other agents
4. **Next steps**: What's needed from recipient
5. **Timeline**: Any urgency or deadlines

### Example Handoff Message:
```
From: product-owner
To: market-researcher

Feature: Social Reading Buddies
Vision: Enable users to have accountability partners for reading goals

Research needed:
- How do reading buddies affect completion rates?
- What features do Goodreads/Bookly offer?
- Would users share reading data?

Success metric: 50% increase in reading streak length
Timeline: Need validation by end of week
```

---

## 🚨 Escalation Triggers

### When to Loop Back:
- **To product-owner**: If scope significantly changes
- **To market-researcher**: If user need unclear
- **To tech-lead**: If performance issues found
- **To designer**: If UX problematic
- **To ios-developer**: If implementation blocked

### Red Flags Requiring Immediate Escalation:
- User data privacy concerns
- Performance degradation > 20%
- Accessibility violations
- App Store guideline conflicts
- Breaking changes to existing features

---

## 📊 Quality Gates

### Each Handoff Must Meet:
- **Completeness**: All required sections filled
- **Clarity**: Next agent knows exactly what to do
- **Quality**: Work meets OneBookAMonth standards
- **Documentation**: Changes recorded properly

### Feature Cannot Ship Without:
- [ ] Market validation complete
- [ ] Technical review passed
- [ ] Design approved
- [ ] Code reviewed and tested
- [ ] Localization ready
- [ ] Metrics tracking implemented

---

## 🎯 OneBookAMonth Specific Considerations

### Always Remember:
1. **Reading First**: Every feature should encourage daily reading
2. **Habit Building**: Focus on consistency over quantity
3. **Visual Progress**: Make achievements tangible
4. **Minimal Friction**: <3 taps to log reading
5. **Privacy**: Reading data is personal

### Common Patterns:
- **Page Entry**: Always through QuickEntrySheet
- **Progress Display**: Use CircularProgressView
- **Calendar**: Integrate with HorizonCalendar
- **Stats**: Update via ItemManager
- **Navigation**: Respect tab structure

---

## 📚 Resources

### Key Documents:
- `/CLAUDE.md`: Project technical guide
- `/.claude/project-context.md`: Current context
- `/.claude/orchestration/templates/`: PRD templates
- `/Model/`: Data structures
- `/View/`: UI components
- `/ViewModel/`: Business logic

### Design References:
- Apple HIG: https://developer.apple.com/design/
- SF Symbols: https://developer.apple.com/sf-symbols/
- HorizonCalendar Docs: Airbnb's calendar library

---

*Last Updated: Current Session*
*Maintained by: All Agents*
*Review: Before each major feature*