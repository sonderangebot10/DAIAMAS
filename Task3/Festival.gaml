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
	float aspect1 <- rnd(0,255)/10;
	float aspect2 <- 0;
	float aspect3 <- 0;
	float aspect4 <- 0;
	float aspect5 <- 0;
	float aspect6 <- 0;
	
	
	reflex send_inform when: playing = 0 {
		aspect1 <- rnd(0,255)/10;
		aspect2 <- rnd(0,255)/10;
		aspect3 <- rnd(0,255)/10;
		aspect4 <- rnd(0,255)/10;
		aspect5 <- rnd(0,255)/10;
		aspect6 <- rnd(0,255)/10;
	
		playing <- rnd(200, 300);
		write '(Time ' + time + '): ' + name + ' sends an inform message to all participants';
		do start_conversation to: list(people) protocol: 'fipa-contract-net' performative: 'inform' contents: [aspect1, aspect2, aspect3, aspect4, aspect5, aspect6, playing];
	}
	
	aspect base {
		float color_ <- aspect1 + aspect2 + aspect3 + aspect4 + aspect5 + aspect6;
		draw square(5) color: rgb(color_, color_, color_) depth: 1;
	}
}

species people skills:[moving, fipa] {
	float aspect1 <- rnd(0,255)/10;
	float aspect2 <- rnd(0,255)/10;
	float aspect3 <- rnd(0,255)/10;
	float aspect4 <- rnd(0,255)/10;
	float aspect5 <- rnd(0,255)/10;
	float aspect6 <- rnd(0,255)/10;
	float color_ <- aspect1 + aspect2 + aspect3 + aspect4 + aspect5 + aspect6;
	
	float best_deal <- 99999;
	point best_deal_p <- nil;
	int in_act <- 0 min: 0 update: in_act - 1;
	
	rgb color <- #green;
	point targetPoint <- nil;
	
	reflex go_wander when: in_act = 0 {
		targetPoint <- point(rnd(0, 100), rnd(0, 100));
		best_deal <- 99999;
	}
	
	reflex receive_inform when: !empty(informs) and in_act = 0 {
		int tmp_;
		loop i over: informs {
			 message proposal <- i;
		     float val <- abs(color_ - (int(proposal.contents[0]) + int(proposal.contents[1]) + int(proposal.contents[2]) + int(proposal.contents[3]) + int(proposal.contents[4]) + int(proposal.contents[5])));
		     write "Contents: " + proposal.contents;
		     write string(val) + " <<<>>> " + best_deal;
		     if(val < best_deal) {
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
		draw circle(1) color: rgb(color_, color_, color_) depth: 1;
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