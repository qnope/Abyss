# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ABYSSES** is a game like Travian or OGame, Clash Of Clan
It is a free game, and it is meant to be a single player.
Explanation of this game are in `ABYSS.md` file.

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