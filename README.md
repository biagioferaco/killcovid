# killcovid
My first Commodore 64 game written in Assembly.
I was in quarantine with an old Commodore 64, and I started playing with BASIC
and graphics.
Then I downloaded VICE and a compiler, I started coding with sprites and this
came out.

![](images/killcovid.gif)

The game is not so much challenging, but it was fun to code in assembly and
see what you can do with few lines of code.

## Rules
When the game starts, the RT Index is at 1.0. Hitting the Covid with the
vaccine reduces it, but when the virus hits the frame it increases (I told you,
it is not so that much).
When the RT Index reaches 2.0, the game is over.

## Sprites Graphics
For the generation of the sprites I used
[SpritePad 1.8.1](https://csdb.dk/release/?id=100657) (the project file is
included in the source files). This program allows you to create several sprite
and generate the *.prg* file that loads your graphics in memory, and that you
can include in source code.

## Compiler
At the beginning I started using DASM and it was fine, but then I moved to
[Kickassembler](http://theweb.dk/KickAssembler/Main.html#frontpage), because it
was a nightmare dealing with strings.

## Debug
For debug, [VICE](https://vice-emu.sourceforge.io) Emulator was used.

## TODO
- Fix the random appear of the Virus.
- Beutify initial screen for the game.
- Fix Exit game.
- Add some music.
