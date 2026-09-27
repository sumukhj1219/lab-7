-- LAB-AI dialog lines (§8). Text is written by the developer.

local M = {}

M.SPEAKER = "LAB-AI"

M.intro = {
	"Dr. Apocalypse, containment breach in Lab 7. Subject Zero is loose.",
	"It's infecting everything it touches, and every infected creature spreads it further. It's a chain reaction.",
	"Your job is to survive as long as you can and keep the outbreak under control.",
}

M.tutorial = {
	move = "Move with WASD. Keep your distance. One touch and you're infected.",
	tower = "Place a stun tower with E. Stun pulses jump between zombies that are close together, so group them up.",
	gas = "Press G to throw mutation gas. Infection can't spread through it. Break the chain!",
	release = "Press F to release an animal. Zombies will chase it instead of you... but anything they bite, they turn.",
	mutation = "Subject Zero is about to mutate. Every 30 seconds it gets stronger.",
	antidote = "You're infected! Press Q to drink an antidote. You only have 3.",
	terminal = "TODO (developer): terminal line - go to the lit terminal and upload research.",
	score = "Stun chains, survival time, and unused antidotes all add to your score. Good luck, Doctor.",
}

M.game_over = {
	"Containment failed. Dr. Apocalypse has joined the experiment.",
	"Out of antidotes. The chain reaction claims another.",
	"Lab 7 is lost. Your research will be... continued by someone else.",
}

return M
