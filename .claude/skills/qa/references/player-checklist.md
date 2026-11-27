# Manual player checklist

Go through only the items the task touches. For each: the device, the OS
version, the result.

## Playback
- [ ] Starting a track: the time to the first sound is acceptable (the threshold is in the PRD).
- [ ] Seeking forward into a part of the file not loaded yet: it plays from the
      new position, the file is not downloaded as a whole.
- [ ] Seeking backward, ±15/30 s.
- [ ] Moving to the next track of the collection automatically and by hand.
- [ ] The end of the last track of the collection: the behavior per the PRD.

## Background and system
- [ ] Minimize the app: the sound continues.
- [ ] Turn off the screen: the sound continues; control from the lock screen works.
- [ ] Bluetooth headset: pause/play/seek from the buttons.
- [ ] Incoming call: pause, and resume after the call.
- [ ] Another app took the audio focus (a video): pause.
- [ ] Unplugging the headphones: pause, not playback through the speaker.

## Position
- [ ] Pause → close the app from the task list → open: the same position (the tolerance is in the PRD).
- [ ] Force-stop the app during playback → the position lags by no more than
      the save interval.
- [ ] Reboot the phone → the position is in place.
- [ ] Two books: the positions do not get mixed up.

## Network
- [ ] Start without a network: a clear message, no crash.
- [ ] The network dropped in the middle of a track: the buffer plays out, then a
      clear state, and after the network is back playback continues.
- [ ] Slow network: no endless loading without an indication.

## Telegram source
- [ ] First sign-in: phone → code → (2FA password) goes through; input errors are clear.
- [ ] A repeated launch does not require signing in.
- [ ] A channel with a large number of files opens without the interface freezing.
- [ ] Rate limiting (if it could be triggered): a clear message, no endless retries.
