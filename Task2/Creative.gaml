model Main

global {
	point auctioneer_loc <- {50, 50};
	bool _won <- false;
	
	int number_of_people <- 6;
	int number_of_auctioneers <- 1;
	
	init{
		create people number:number_of_people;
		create auctioneer number:number_of_auctioneers;
		create won_ number:1;
		write 'Initiated';
	}
}

species people skills:[moving, fipa] {
	bool won <- false;
	point prev_point <- nil;
	
	rgb color <- #green;
	bool bad <- flip(0.5);
	point targetPoint <- nil;
	bool inAuction <- false;
	
	int angle <- 0 update: angle + 10;
	
	int max_price <- rnd(10, 80);
	
	aspect base {
		draw circle(2) color: color;
		draw ('name: ' + self.name + ' price: ' + max_price) color: #black font:font("Helvetica", 20 , #bold);
	}
	
	reflex beIdle when: targetPoint = nil {
		do wander speed: 0.1;
		
		if(bad){
			color <- #red;
		}
	}
	
	reflex hasWon when: won {
		location <- {(sin(angle) * 4) + prev_point.x, (cos(angle) * 4) + prev_point.y};
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
			if (bad) {
				do propose message: proposalFromInitiator contents: ['Fake'];	
				do die;
				
			} else {
				do propose message: proposalFromInitiator contents: ['Agree'];	
				prev_point <- location;
				won <- true;
				_won <- true;
			}
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
		write length(proposes);
		message sender <- proposes[0];
		if (sender.contents[0] = 'Fake') {
			write('Fake');
		} else {
			write length(proposes);
			write '(Time ' + time + '): ' + name + ' received agree messages';
			write '\t' + name + ' receives a propose message from ' + sender.sender + ' for: ' + price;
			sold <- true;
		}
		
		
	}
	
	reflex read_inform_message when: !(empty(informs)) and time=2 {
		loop i over: informs {
			write 'Join from: ' + string(i.sender);
			add i.sender to: listeners;
		}
	}
}

species won_ {
	rgb color_ <- #white;
	init {
		location <- {50, 50};
	}
	
	aspect base {
		draw square(99) color: color_;
	}
	
	reflex do_rain {
		if(_won){			
			if(color_ = #white or color_ = rgb(255,0,0)){
				color_ <- rgb(0,0,255);
			}
			else if(color_ = rgb(0,0,255)){
				color_ <- rgb(0,255,0);
			}
			else if(color_ = rgb(0,255,0)){
				color_ <- rgb(255,0,0);
			}
		}
		else {
			color_ <- #white;
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
			species won_ aspect:base;
			species people aspect:base;
			species auctioneer aspect:base;
		}
	}
}