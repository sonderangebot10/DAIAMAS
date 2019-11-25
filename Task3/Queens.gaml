model Main

global {
	int size_board <- 12;
	init {
		queen parent;
		loop i from: 0 to: size_board - 1 {
			//creating queens with their own collumns
			create queen returns: column_queen {
				pred <- parent;
				col <- i;
				location <- {-20, -20, 0};
			}
			parent <- column_queen[0];
		}
	}
}

species queen skills:[moving] {
	rgb color <- #blue;
	point targetPoint <- nil;
	bool positioned <- false;
	int row <- -1;
	int col;
	queen pred;
	
	
	//check if new cell doesn not overlap with previous ones
	bool is_pos(chess_grid new_cell) {
		if (pred = nil) {
			return true;
		}
		//check row, col and diagonal
		return pred.row != new_cell.grid_y and
			abs(pred.row - new_cell.grid_y) != abs(pred.col - new_cell.grid_x) and 
			pred.is_pos(new_cell);
	}
	
	//simple move to target reflex
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			targetPoint <- nil;
		}
		do goto target: targetPoint;
	}
	
	//remove when: targetPoint = nil to remove waiting time
	reflex find_pos when: !positioned and (pred = nil or pred.positioned = true) {
		if (row < size_board - 1) {
			loop i from: (row + 1) to: size_board - 1 {
				chess_grid cell <- chess_grid grid_at {col, i};
				
				if (is_pos(cell)) {
					targetPoint <- cell.location;
					row <- i;
					positioned <- true;
					return;
				}
			}
		}
		row <- -1;
		pred.positioned <- false;
	}
	
	aspect base {
		draw circle(3) color: color depth: 3;
		draw ('name: ' + self.name) color: #blue font:font("Helvetica", 20 , #bold);
	}
}

grid chess_grid width: size_board height: size_board neighbors: 4 {
    rgb color <- (grid_x + grid_y) mod 2 = 0 ? #white : #black;
}

experiment my_experiment type: gui {
	output {
		display map_3D type: opengl {
			grid chess_grid lines: #black;
			species queen aspect:base;
		}
	}
}