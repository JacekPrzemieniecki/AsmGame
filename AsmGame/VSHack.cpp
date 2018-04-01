// VS only rebuilds the project if any .cpp file changed
// so we include our asm files (wrapped in ;/* ;*/)
// to get a rebuild whenever they change
#include "Main.asm"
#include "Game.asm"
#include "Sprites.asm"
