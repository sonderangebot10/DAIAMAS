model Creative

global {
	point info_stand_loc <- {50, 50};
	point tent_loc <- {90, 90, 10};
	
	bool rain <- false;
	
	int number_of_people <- 30;
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
		create tent number:1;
		create rain_ number:1;
	}
}

species tent {
	init {
		location <- tent_loc;
	}
	
	aspect base {
		draw square(20) color: #black depth: 1;
	}
}

species rain_ {
	rgb color_ <- #white;
	init {
		location <- {50, 50};
	}
	
	aspect base {
		draw square(99) color: color_;
	}
	
	reflex do_rain {
		if(rain){
			color_ <- (color_ = #white) ? rgb(0, 255, 255) : #white;
		}
		else {
			color_ <- #white;
		}
	}
}

species people skills:[moving] {
	int is_hungry <- rnd (start_min_food, max_food) min: 0 max: max_food;
	int is_thirsty <- rnd (start_min_water, max_water) min: 0 max: max_water;
	
	rgb color <- #green;
	point targetPoint <- nil;
	point prev_point <- nil;
	
	geometry circle_ <- smooth(circle(1), 0.0);
	aspect base {
		draw circle(1) color: color depth: 1;
		
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
	
	reflex hide_under_tent when: rain {
		if(prev_point = nil and color = #green){
			prev_point <- location;
		}
		targetPoint <- {rnd(95, 99), rnd(95, 99)};
	}
	
	reflex go_back when: !rain and prev_point != nil {
		targetPoint <- prev_point;
		prev_point <- nil;
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
		
		is_hungry <- is_hungry - 1;
		is_thirsty <- is_thirsty - 1;
		
		if(color != #green){
			targetPoint <- info_stand_loc;
		}
	}
	
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			targetPoint <- nil;
		}
		do goto target: targetPoint;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) = 0 {
		ask info_stand at_distance 1 {
			if (myself.is_hungry = 0) {
				myself.targetPoint <- self.food;
			}
			if (myself.is_thirsty = 0) {
				myself.targetPoint <- self.water;
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
		draw pyramid(5) color: #yellow depth: 10;
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
	geometry square_ <- smooth(square(4), 0.75);
	aspect base {
		draw square(4) color: #red depth: 5;
	}
	
	init {
		point init_loc <- flip(0.5) ? {rnd(0, 100), rnd(0, 80)} : {rnd(0, 80), rnd(0, 100)};
		location <- init_loc;
	}
}

species water_stand {
	geometry square_ <- smooth(square(4), 0.75);
	aspect base {
		draw square(4) color: #blue depth: 5;
	}
	
	init {
		point init_loc <- flip(0.5) ? {rnd(0, 100), rnd(0, 80)} : {rnd(0, 80), rnd(0, 100)};
		location <- init_loc;
	}
}

grid festival_map width: 1 height: 1 {
    rgb color <- rgb(255, 255, 255) ;
}

experiment my_experiment type: gui {
	parameter "Rain" var: rain;
	output {
		monitor "rain" value: rain;
		display map_3D type: opengl{
			grid festival_map lines: #black;
			species rain_ aspect:base;
			species people aspect:base;
			species info_stand aspect:base;
			species food_court aspect:base;
			species water_stand aspect:base;
			species tent aspect:base;
		}
	}
}