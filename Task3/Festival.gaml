model Creative

//Display clearly that agents pick the selection based on their utility.

global {
	
	int number_of_people <- 10;
	
	init{
		create people number:number_of_people;
		create stage number:4;
	}
}

species stage skills:[moving, fipa] {		
	int playing <- 0 min: 0 update: playing - 1;
	
	reflex send_inform when: playing = 0 {
		float aspect1 <- rnd(0,100)/100;
		float aspect2 <- rnd(0,100)/100;
		float aspect3 <- rnd(0,100)/100;
		float aspect4 <- rnd(0,100)/100;
		float aspect5 <- rnd(0,100)/100;
		float aspect6 <- rnd(0,100)/100;
	
		playing <- rnd(50, 100);
		write '(Time ' + time + '): ' + name + ' sends an inform message to all participants';
		do start_conversation to: list(people) protocol: 'fipa-contract-net' performative: 'inform' contents: [aspect1, aspect2, aspect3, aspect4, aspect5, aspect6, playing];
	}
	
	aspect base {
		draw square(5) color: #black depth: 1;
	}
}

species people skills:[moving, fipa] {
	float aspect1 <- rnd(0,100)/100;
	float aspect2 <- rnd(0,100)/100;
	float aspect3 <- rnd(0,100)/100;
	float aspect4 <- rnd(0,100)/100;
	float aspect5 <- rnd(0,100)/100;
	float aspect6 <- rnd(0,100)/100;
	
	float best_deal <- 0;
	point best_deal_p <- nil;
	int in_act <- 0 min: 0 update: in_act - 1;
	
	rgb color <- #green;
	point targetPoint <- nil;
	
	reflex go_wander when: in_act = 1 {
		targetPoint <- point(rnd(0, 100), rnd(0, 100));
		best_deal <- 0;
	}
	
	reflex receive_inform when: !empty(informs) and in_act = 0 {
		int tmp_;
		loop i over: informs {
			 message proposal <- i;
		     float val <- aspect1 * float(proposal.contents[0]) + aspect2 * float(proposal.contents[1]) + aspect3 * float(proposal.contents[2]) + aspect4 * float(proposal.contents[3]) + aspect5 * float(proposal.contents[4]) + aspect6 * float(proposal.contents[5]);
		     write "Contents: " + proposal.contents;
		     write string(val) + " <<<>>> " + best_deal;
		     if(val > best_deal) {
		     	best_deal <- val;
		     	write name + ' chose to go to ' + proposal.sender;
		     	best_deal_p <- proposal.sender; 
		     	tmp_ <- int(proposal.contents[6]);
			 }
		}
		targetPoint <- best_deal_p;
		in_act <- tmp_;
	}
	
	geometry circle_ <- smooth(circle(1), 0.0);
	aspect base {
		draw circle(1) color: color depth: 1;
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
		
	}
	
	reflex moveToTarget when: targetPoint != nil {
		if(targetPoint = location) {
			targetPoint <- nil;
		}
		do goto target: targetPoint;
	}
}


grid festival_map width: 1 height: 1 {
    rgb color <- rgb(255, 255, 255) ;
}

experiment my_experiment type: gui {
	parameter "People" var: number_of_people;
	output {
		display map_3D type: opengl{
			grid festival_map lines: #black;
			species stage aspect:base;
			species people aspect:base;
		}
	}
}