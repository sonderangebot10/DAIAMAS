model Challenge1

global {
	point info_stand_loc <- {50, 50};
	
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
	}
}

species people skills:[moving] {
	int is_hungry <- rnd (start_min_food, max_food) min: 0 max: max_food;
	int is_thirsty <- rnd (start_min_water, max_water) min: 0 max: max_water;
	
	int distance_traveled <- 0 update: (color != #green) ? distance_traveled + 1 : distance_traveled;
	int cycle_count <- 0 update: cycle_count + 1;
	
	reflex steps {
		if(cycle_count = 10000) {
			write(distance_traveled);
		}
	}
	
	point food <- nil update: flip(0.002) ? nil : food;
	point water <- nil update: flip(0.002) ? nil : water;
	
	rgb color <- #green;
	point targetPoint <- nil;
	
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
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
		
		is_hungry <- is_hungry - 1;
		is_thirsty <- is_thirsty - 1;
		
		if(color != #green){
			targetPoint <- info_stand_loc;
			if(color = #blue and water != nil){
				targetPoint <- water;
			}
			if((color = #red or color = #black) and food != nil){
				targetPoint <- food;
			}
		}
	}
	
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			targetPoint <- nil;
		}
		do goto target: targetPoint;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) = 0 {		
		ask info_stand  at_distance 1 {
			if (myself.is_hungry = 0) {
				myself.food <- self.food;
			}
			if (myself.is_thirsty = 0) {
				myself.water <- self.water;
			}
		}
		
		ask people at_distance 5 {
			if (myself.is_hungry = 0) {
				if(self.food != nil){
					myself.food <- self.food;
				}
			}
			if (myself.is_thirsty = 0) {
				if(self.water != nil){
					myself.water <- self.water;
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

species info_stand {		
	list<point> waters;
	point water;
	
	list<point> foods;
	point food;
	
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
		}
	}
}