# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ABYSSES** is a 100% offline mobile strategy/management game (iOS 16+, Android 12+) where the player manages an underwater colony alongside 50-100 AI-driven rival colonies. The game is in **pre-implementation/design phase** — no source code exists yet.

The complete Game Design Document is in `Abyss_v4.md` (v4.0 — the shift from server-based v3.0 to fully local architecture). Visual assets (112 SVGs) are in `assets/`.

## Planned Tech Stack

- **Framework:** Flutter 3.x + Dart
- **2D Engine:** Flame Engine (map, colonies, animations)
- **State Management:** Riverpod
- **Database:** Drift (SQLite ORM) — type-safe, offline-first
- **AI:** Utility AI (decision scoring) + Behavior Trees (tactical execution), run on Dart Isolates
- **Notifications:** flutter_local_notifications

## Planned Build Commands

Once the Flutter project is initialized:
```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run all tests
flutter test <file>      # Run a single test file
flutter analyze          # Lint (Dart analyzer)
dart format .            # Format code
flutter build apk        # Build Android
flutter build ios        # Build iOS
```

## Architecture (from GDD)

The codebase follows a layered architecture under `lib/`:

- **`core/`** — Database (Drift tables, DAOs, migrations), constants (game balancing), utilities
- **`domain/models/`** — Data models: Colony, Fleet, Building, Resource, Personality
- **`engine/`** — Game logic, separated into three subsystems:
  - **`ai/`** — Two-layer AI: Utility AI scores 10-15 action categories, Behavior Trees execute tactics. 8 personality archetypes with 5-axis traits. Memory system (~31 KB/colony)
  - **`combat/`** — Instant resolution with rock-paper-scissors triangle (Torpedoes > Swarms > Leviathans > Torpedoes). +40% bonus / -20% malus. 15-round max
  - **`simulation/`** — Tick-based game loop (5s/30s/5min tiers by colony distance) + catch-up engine for offline time
- **`application/`** — Riverpod providers bridging engine and UI
- **`presentation/`** — 5 screens (Base, Messages, Fleet, Map, Research) + reusable widgets
- **`infrastructure/`** — Local notifications, save manager, settings

## Key Design Decisions

- **No server, no network** — Everything runs on-device. Zero API cost. Deterministic simulation.
- **AI activity tiers** — Active (~20 colonies, full AI every 5s), Semi-Active (~30, reduced every 30s), Dormant (~50, catch-up every 5min). Target: ~22ms/cycle CPU overhead.
- **Message templates** — AI communication uses ~59 templates (situation × personality × variant) instead of LLM generation.
- **Database sizing** — ~4-6 MB initial, ~135 MB after 6 months of play (10 Drift/SQLite tables).
- **4 resources:** Credits, Biomass, Minerals, Energy. **10 building modules.** **9 combat unit types** (3 classes × 3 tiers). **15 technologies** across 5 branches.

## Language

The GDD and game content are in **French**. Code identifiers, comments, and documentation should follow whatever convention is established at project initialization.
