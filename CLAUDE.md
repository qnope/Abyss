# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ABYSSES** is a game like Travian or OGame, Clash Of Clan
It is a free game, and it is meant to be a single player.
Explanation of this game are in `ABYSS.md` file.

It's a turn by turn game. Instead of waiting for hours, we are doing actions, and at the end, we press the "next turn" button.

We have resources, army, technologies etc.

## Tech
1. Dart
2. Flutter
3. Hive for saving
4. Should run on iOS, Android, Web.

## Rules
1. Always design component that are reusable
2. Never have object with `initialize()` function. Object should be constructed or not.
3. Always run `flutter analyze` and `flutter test` to be sure everything is fine.
4. Always target under 150 lines of code by file.
5. Target architecture of 5 layers.
6. Theme is in `lib/presentation/theme/`. Always use it when creating UI component.