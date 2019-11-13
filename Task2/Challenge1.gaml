model Challenge1

global {	
	int number_of_people <- 3;
	int number_of_auctioneers <- 2;
	
	init{
		create people number:number_of_people;
		create auctioneer number:number_of_auctioneers;
		write 'Initiated';
	}
}

species people skills:[moving, fipa] {
	bool bought <- false;
	
	int interest <- rnd(1,3);
	
	rgb color <- #black;
	point targetPoint <- nil;
	bool inAuction <- false;
	
	int max_price <- rnd(40, 80);
	
	aspect base {
		draw circle(2) color: color;
		draw ('name: ' + self.name + ' price: ' + max_price) color: #black font:font("Helvetica", 20 , #bold);
		if(interest = 1){
			color <- #blue;
		}
		if(interest = 2){
			color <- #red;
		}
		if(interest = 3){
			color <- #green;
		}
		if(bought){
			color <- #yellow;
		}
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
	}
	
	reflex receive_informs_from_initiator when: !empty(informs) and !inAuction {
		loop inform over: informs {
			message proposalFromInitiator <- inform;
			if(proposalFromInitiator.contents[0] = interest){
				do inform message: proposalFromInitiator contents: ['Join'] ;
				inAuction <- true;
			}
		}
	}
	
	reflex receive_requests_from_initiator when: !empty(cfps) and !bought {
		message proposalFromInitiator <- cfps[0];
		
		write '(Time ' + time + '): ' + name + ' receives a request message from ' + agent(proposalFromInitiator.sender).name + ' and the price is: ' + proposalFromInitiator.contents;
		
		int offer_price <- int(proposalFromInitiator.contents[0]);
		write "Received Price " + offer_price;
		if(offer_price > max_price){
			do refuse message: proposalFromInitiator contents: ['Refuse'] ;
		}
		else {
			do propose message: proposalFromInitiator contents: ['Agree'] ;
			bought <- true;
		}
	}
}

species auctioneer skills:[fipa] {	
	int interest <- rnd(1,3);

	int min_price <- 10;
	int price <- rnd(80, 100);
	int start <- rnd(2,10);
	list<people> listeners;
	
	bool sold <- false;
	
	rgb color <- #black;
	
	aspect base {
		draw square(10) color: color;
		draw ('auction: ' + self.name + ' price: ' + price) color: #black font:font("Helvetica", 20 , #plain);
		
		if(interest = 1){
			color <- #blue;
		}
		if(interest = 2){
			color <- #red;
		}
		if(interest = 3){
			color <- #green;
		}
	}
	
	reflex send_request when: (time=1) {
		write '(Time ' + time + '): ' + name + ' sends an inform message to all participants';
		do start_conversation to: list(people) protocol: 'fipa-contract-net' performative: 'inform' contents: [interest];
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
			write 'Join from: ' + string(i.sender) + ' To auction: ' + self.name;
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