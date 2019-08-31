# SegaGenesis
## Experiments in 68K Assembly for the Sega Genesis
The Sega Genesis is extremely near and dear to my heart. I can hardly believe it took me this long to get inspired to start playing with it. Will hopefully have samples that others can learn from and will try to create some semblence of a game.
## Tools
- [Easy68k Development Suite](http://www.easy68k.com/)
- [Gens K-Mod](https://segaretro.org/Gens_KMod)
- [Pastry Editor](https://github.com/JIoffe/PastryEditor) (Angular8 Tool I hacked together to bring assets into m68k code)

## Samples
These are basic but fully runnable examples of different elements of Genesis development as I learn them. They may or may not follow any best practices, so please review at your own risk. My goal is to assemble enough common code that covers enough boilerplate to reuse in more game-like projects. 

### ChangeBackdrop
Everything is self-contained to get the Genesis initialized. The buttons A, B and C are mapped to the Red, Green and Blue channels, respectfully. Pressing multiple buttons will mix channels.

### Sonnet18
Example of printing text using font tiles and multiple scroll planes. The NTSC resolution actually is enough to just barely contain the entire sonnet, but I only included a small snippet. Use the D-Pad to move Shakespeare's portrait around. 

### Asteroid Field
Scatters a small set of star tiles to the background and an asteroid pattern to the foreground. Modifies CRAM to make the stars shine and flicker. Hoping to add a little spaceship sprite you can move with the DPad. Possible pew pew.

## References
Anything that actually runs is thanks to the information on the following sites:
- [MrJester's MC68K Tutorial](http://mrjester.hapisan.com/04_MC68/)
- [Hugues Johnson's Genesis Articles](https://huguesjohnson.com/programming/)
- [Hacking-Cult's Resource on Genesis](http://www.hacking-cult.org/)
- [BigEvilCorporation's Samples](https://github.com/BigEvilCorporation/megadrive_samples/tree/master/1_hello_world)
