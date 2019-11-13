model Challenge2

global {
	point info_stand_loc <- {50, 50};
	point guard_loc <- {10, 10};
	
	int number_of_people <- 10;
	int number_of_information <- 1;
	int number_of_food_courts <- 4;
	int number_of_water_stands <- 4;
	
	int max_food <- 300;
	int max_water <- 300;
	
	int start_min_food <- 50;
	int start_min_water <- 50;
	
	init{
		create people number:number_of_people;
		create info_stand number:number_of_information;
		create food_court number:number_of_food_courts ;
		create water_stand number:number_of_water_stands;
		create guard number:1;
	}
}

species people skills:[moving] {
	int is_hungry <- rnd (start_min_food, max_food) min: 0 max: max_food;
	int is_thirsty <- rnd (start_min_water, max_water) min: 0 max: max_water;
	
	point bad_guy <- nil;
	
	rgb color <- #green;
	point targetPoint <- nil;
	
	bool bad <- false;
	
	aspect base {
		draw circle(2) color: color;
		
		if(is_hungry = 0 and is_thirsty = 0) {
			color <- #black;
		}
		else if(is_hungry = 0) {
			color <- #red;
		}
		else if(is_thirsty = 0) {
			color <- #blue;
		}
		else {
			color <- #green;
		}
		
		if(bad) {
			color <- #pink;
		}
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
		
		is_hungry <- is_hungry - 1;
		is_thirsty <- is_thirsty - 1;
		
		if(color != #green and color != #pink){
			targetPoint <- info_stand_loc;
		}
		
		bad <- bad ? true : flip(0.001);
	}
	
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			if(targetPoint = bad_guy){
				bad_guy <- nil;
			}
			targetPoint <- nil;
		}
		do goto target: targetPoint;
	}

	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) = 0 {
		ask info_stand at_distance 1 {
			if(myself.bad_guy != nil){
				myself.targetPoint <- self.guard_location;
			}
			else if (myself.is_hungry = 0) {
				myself.targetPoint <- self.food;
			}
			else if (myself.is_thirsty = 0) {
				myself.targetPoint <- self.water;
			}
		}
		
		ask guard at_distance 5 {
			if(myself.bad_guy != nil){
				myself.targetPoint <- myself.bad_guy;
				self.targetPoint <- myself.bad_guy;
			}
		}
		
		ask people at_distance 100 {
			if(self.bad) {
				myself.bad_guy <- self.location;
				if(myself.bad_guy = nil){
				myself.targetPoint <- info_stand_loc;
				}
			}			
		}
		
		ask water_stand at_distance 1 {
			myself.is_thirsty <- max_water;
			myself.targetPoint <- {rnd(0,100), rnd(0,100)};
		}
		
		ask food_court at_distance 1 {
			myself.is_hungry <- max_food;
			myself.targetPoint <- {rnd(0,100), rnd(0,100)};
		}
	}
}

species guard skills:[moving] {
	point targetPoint <- nil;
	
	init {
		location <- guard_loc;
	}
	
	aspect base {
		draw circle(4) color: #black;
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
	}
	
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			targetPoint <- nil;
		}
		do goto target: targetPoint speed:1.5;
	}
	
	reflex arrest{
		ask people at_distance 5 {
			if(self.bad) {
				myself.targetPoint <- guard_loc;
				do die;
			}
		}
		if(targetPoint = location){
			targetPoint <- guard_loc;
		}
	}

	
}

species info_stand {		
	list<point> waters;
	point water;
	
	list<point> foods;
	point food;
	
	point guard_location <- guard_loc;
	
	aspect base {
		draw circle(5) color: #yellow;
	}
	
	init {
		location <- info_stand_loc;
	}
	
	reflex update {
		if(length(waters) = 0 or length(foods) = 0) {
			ask water_stand {
				add {self.location.x, self.location.y} to: myself.waters;
			}
			ask food_court {
				add {self.location.x, self.location.y} to: myself.foods;
			}
		}
		else {
			water <- waters[rnd (0, length(waters) - 1)];
			food <- foods[rnd (0, length(foods) - 1)];
		}
	}
}

species food_court {
	aspect base {
		draw circle(4) color: #red;
	}
}

species water_stand {
	aspect base {
		draw circle(4) color: #blue;
	}
}

//species rats skills:[moving] {
//	
//	reflex attack when: !empty(people at_distance attack_range) {
//		ask people at_distance attack_range {
//			if (self.is_infected) {
//				myself.is_infected <- true;
//			}
//			else if (myself.is_infected) {
//				self.is_infected <- true;
//			}
//		}
//	}
//}

experiment my_experiment type: gui {
	output {
		display my_display {
			species people aspect:base;
			species info_stand aspect:base;
			species food_court aspect:base;
			species water_stand aspect:base;
			species guard aspect:base;
		}
	}
}