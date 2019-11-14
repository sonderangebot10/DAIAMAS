model Main

global {
	point auctioneer_loc <- {50, 50};
	
	int number_of_people <- 2;
	int number_of_auctioneers <- 1;
	
	init{
		create people number:number_of_people;
		create auctioneer number:number_of_auctioneers;
		write 'Initiated';
	}
}

species people skills:[moving, fipa] {	
	rgb color <- #green;
	point targetPoint <- nil;
	bool inAuction <- false;
	
	int max_price <- rnd(1, 80);
	
	aspect base {
		draw circle(2) color: color;
		draw ('name: ' + self.name + ' price: ' + max_price) color: #black font:font("Helvetica", 20 , #bold);
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
	}
	
	reflex receive_informs_from_auctioneer when: !empty(informs) and !inAuction {
		message proposalFromInitiator <- informs[0];
		do inform message: proposalFromInitiator contents: [max_price] ;
		inAuction <- true;
		do end_conversation message: proposalFromInitiator contents: ['Joined'];
	}
}

species auctioneer skills:[fipa] {
	int price <- 0;
	
	list<people> listeners;
	
	bool sold <- false;
	
	rgb color <- #black;
	init {
		location <- auctioneer_loc;
	}
	
	aspect base {
		draw square(10) color: color;
		draw ('auction: ' + self.name + ' price: ' + price) color: #black font:font("Helvetica", 20 , #plain);
	}
	
	reflex send_request when: (time=1) {
		write '(Time ' + time + '): ' + name + ' sends an inform message to all participants';
		do start_conversation to: list(people) protocol: 'fipa-contract-net' performative: 'inform' contents: ['initiation'];
	}
	
	reflex read_inform_message when: !(empty(informs)) and time=2 {
		int max_proposal <- 0;
		people winner;
		
		loop i over: informs {
			write 'Join from: ' + string(i.sender);
			if(int(i.contents[0]) > max_proposal){
				max_proposal <- int(i.contents[0]);
				winner <- i.sender;
			}
		}
		
		write 'Sold for: ' + max_proposal + ' To: ' + winner;
	}
}

grid festival_map width: 1 height: 1 {
    rgb color <- rgb(255, 255, 255) ;
}

experiment my_experiment type: gui {
	output {
		display map_3D type: opengl{
			grid festival_map lines: #black;
			species people aspect:base;
			species auctioneer aspect:base;
		}
	}
}