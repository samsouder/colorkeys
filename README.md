Color Keys is a simple, fullscreen application that shows large letters and plays sounds when keys are pressed. It is helpful when you have children who wish to bang on the keys, which tends to cause bad things with most applications.

**Note, to exit you must press the `escape` key 15 times.**

The sounds come from `/Library/Audio/Apple Loops/Apple/iLife Sound Effects/`, so you must have the iLife sound effects installed in that location to hear them. I have limited the sound effects to only sounds less than 20 seconds in length and I have removed some of the ones that didn't make sense to hear for me. YMMV, feel free to modify `kSoundsPath` and `kSoundDurationLimit` in `AppController.m` if you wish to change things up.