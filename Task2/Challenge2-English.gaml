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
	
	int max_price <- rnd(40, 80);
	
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
	people previous_bidder <- nil;
	int previous_length <- 0;
	
	int price <- 20;
	
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

	reflex receive_agree_messages when: !empty(proposes) and !sold {
		write(length(proposes) - previous_length);
		if(length(proposes) - previous_length = 0) {
			write  '(Time ' + time + '): ' + previous_bidder + ' won the auction with price: ' + price;
			sold <- true;
		}
		else if (length(proposes) - previous_length = 1) {
			write  '(Time ' + time + '): ' + proposes[0].sender + ' won the auction with price: ' + price;
			sold <- true;
		}
		else {
			previous_bidder <- proposes[0].sender;
		}
		
		previous_length <- length(proposes);
	}
	
	reflex send_request_to_participants when: (!sold and length(listeners) > 0) and !sold {
		price <- price + 2;
		write '(Time ' + time + '): ' + name + ' sends a request message to listeners';
		do start_conversation to: listeners protocol: 'fipa-contract-net' performative: 'cfp' contents: [price];
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