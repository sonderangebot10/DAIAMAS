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
		do inform message: proposalFromInitiator contents: ['Join'] ;
		inAuction <- true;
		do end_conversation message: proposalFromInitiator contents: ['Joined'];
	}
	
	reflex receive_requests_from_initiator when: !empty(cfps) {
		message proposalFromInitiator <- cfps[0];
		
		write '(Time ' + time + '): ' + name + ' receives a request message from ' + agent(proposalFromInitiator.sender).name + ' and the price is: ' + proposalFromInitiator.contents;
		
		int offer_price <- int(proposalFromInitiator.contents[0]);
		write "Received Price " + offer_price;
		if(offer_price > max_price){
			do refuse message: proposalFromInitiator contents: ['Refuse'] ;
		}
		else {
			do propose message: proposalFromInitiator contents: ['Agree'] ;
		}
	}
}

species auctioneer skills:[fipa] {
	int min_price <- 20;
	int price <- 100;
	
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
	
	reflex send_request_to_participants when: (!sold and time mod 2 = 0 and length(listeners) > 0) {
		price <- price - rnd(1,3);
		write '(Time ' + time + '): ' + name + ' sends a request message to listeners';
		if(price < min_price){
			write 'Auction ended, price too low!';
			sold <- true;
		}
		else {
			do start_conversation to: listeners protocol: 'fipa-contract-net' performative: 'cfp' contents: [price];
		}
	}

	reflex receive_agree_messages when: !empty(proposes) and !sold {
		sold <- true;
		write '(Time ' + time + '): ' + name + ' received agree messages';
		write '\t' + name + ' receives a propose message from ' + proposes[0].sender + ' with content ' + proposes[0].contents;
	}
	
	reflex read_inform_message when: !(empty(informs)) and time=2 {
		loop i over: informs {
			write 'Join from: ' + string(i.sender);
			add i.sender to: listeners;
		}
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