# Sound Effects

- Shared learning-feedback audio is managed by `SoundController` in `lib/services/sound_controller.dart`.
- Register `SoundController` with Provider at app startup and inject it into lesson notifiers instead of playing global feedback sounds directly from UI widgets.
- Store bundled feedback effects in `assets/sound/`. Supported events are correct, alternate correct, wrong, streak, and finish.
- Use sounds only for learning feedback and lesson completion; avoid generic navigation or scrolling sounds.
