# Claude Agents & Orchestration

This directory contains AI agents and orchestration system for software development projects.

## 📚 Structure

### Agents
The `/agents` directory contains specialized agents for development:
- **product-owner**: User-centric product strategy and requirements
- **market-researcher**: Market validation and competitive analysis
- **tech-lead**: Architecture design and technical decisions
- **designer**: Design system and UI/UX patterns
- **ios-developer**: SwiftUI implementation specialist
- **localization-expert**: Multi-language support for Swift/SwiftUI

### Orchestration
The `/orchestration` directory contains a generic workflow system that can be used for any feature development. The templates and workflows are project-agnostic and work with the agents above.

## 🚀 Quick Start

### For New Features
1. Start with `elon` agent for product vision
2. Follow the orchestration workflow for systematic development
3. Use templates in `/orchestration/templates/` for documentation

### For Bug Fixes
1. Start directly with `ios-developer` 
2. Loop in other agents as needed

## 📖 Key Documents

- **Project Context**: `/project-context.md` - Project-specific context (create for each project)
- **Agent Handoff Guide**: `/orchestration/agent-handoff-guide.md` - Collaboration patterns
- **PRD Template**: `/orchestration/templates/prd-template.md` - Standard product requirements

## 🎯 Usage

These agents adapt to the current project context. They will:
1. Read project-specific files (CLAUDE.md, project-context.md)
2. Understand the technology stack and architecture
3. Follow established patterns in the codebase

---

*Note: Both agents and orchestration are designed to be reusable across different projects. They automatically adapt based on project context.*