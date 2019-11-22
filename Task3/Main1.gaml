model Main

global {
	int size_board <- 4;
	int queens <- 0;
	
	float step <- 100 / size_board / 2;
	int number_of_queens <- size_board;
	list<point> board;
	
	init {
		create queen number:number_of_queens;
		
		loop x from: 1 to: size_board  { 
     		loop y from: 1 to: size_board {
    			 add {float(step * (y * 2) - step), float(step* (x * 2) - step), 0} to: board;
			}	
		}
				
		write 'Initiated';
		write 'Map: ' + board + ' ';
	}
}

species queen skills:[moving] {
	rgb color <- #blue;
	point targetPoint <- nil;
	int tried_count <- -1 max: size_board - 1;
	bool established <- false;
	
	init {
		name <- queens;
		queens <- queens + 1; 
		
		if(name = '0') {
			tried_count <- 0;
		}
	}
	
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			targetPoint <- nil;
			established <- true;			
			
			ask queen at_distance 1000 {
				if int(self.name) = int(myself.name) + 1 {
					self.tried_count <- self.tried_count + 1;
				}
			}
		}
		do goto target: targetPoint;
	}
	
	reflex mov when: tried_count != -1 and !established {
		if(location != board[tried_count]){
			targetPoint <- board[tried_count + size_board * int(name)];
		}
	}
	
	aspect base {
		draw circle(3) color: color depth: 3;
		draw ('name: ' + self.name) color: #black font:font("Helvetica", 20 , #bold);
	}
}

grid festival_map width: size_board height: size_board {
    rgb color <- rgb(255, 255, 255) ;
}

experiment my_experiment type: gui {
	output {
		display map_3D type: opengl{
			grid festival_map lines: #black;
			species queen aspect:base;
		}
	}
}