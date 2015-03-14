
TODO:

	Generate random squares. Get simple separation working.

NOTES:
	
	Tinykeep reddit post:
		https://www.reddit.com/r/gamedev/comments/1dlwc4/procedural_dungeon_generation_algorithm_explained/

	Linked article with really simple separation logic
		http://gamedevelopment.tutsplus.com/tutorials/the-three-simple-rules-of-flocking-behaviors-alignment-cohesion-and-separation--gamedev-3444

	A thought I had: If you have priorities for each of your rectangles then you could adjust them based on their relative priorities. For example if two rectangles have equal priority then they should both move the same distance away from each other for a more diplomatic separation. If the priorities are different then the distances should be proportional to their relative priorities. So rectangle A moves this much: 
		( priority_A / (priority_A + priority_B) ) * overlap distance
