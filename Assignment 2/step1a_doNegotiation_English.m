% step1a_doNegotiation_English.m description
% Add your English agent models and edit this file to create your English
% auction.

% This file uses the matrix generated in determineCommunicationCandidates.m
% (in step1_performCommunication.m) that contains every communication
% candidate for each flight. The function
% determineRoutingAndSynchronization.m then determines if formation is
% possible for a pair of flights, the optimal joining- and splitting point,
% and what their respective speeds should be towards the joining point to
% arrive at the same time. The function calculateFuelSavings.m then
% determines how much cumulative fuel is saved when accepting this
% formation flight. If accepted, the properties in flightsData (the matrix
% that contains all information of each flight) for both flights are
% updated in step1c_updateProperties.m.

% Make sure that the following variables are assigned to those belonging to
% the combination of the manager/auctioneer agent (acNr1) and the winning
% contractor/bidding agent (acNr2): acNr2, fuelSavingsOffer,
% divisionFutureSavings. Also: Xjoining, Yjoining, Xsplitting, Ysplitting,
% VsegmentAJ_acNr1, VsegmentBJ_acNr2, timeAdded_acNr1, timeAdded_acNr2,
% potentialFuelSavings. These variables follow from
% step1b_routingSynchronizationFuelSavings.m and differ for every
% combination of acNr1 and acNr2.

% One way of doing this is storing them as part of the bid, and then
% defining them again when the manager awards the contract in the CNP/the
% winning bid is selected in the auctions.

% It contains two files: step1b_routingSynchronizationFuelSavings.m
% (determineRoutingAndSynchronization.m, calculateFuelSavings.m) and
% step1c_updateProperties.m.


% Find the agent that can communicate with most others and choose it as a
% auctioneer
most_connected_agents_index = find(communicationCandidates(:,end));
% Pick first index to be auctioneer
auctioneer = communicationCandidates(most_connected_agents_index(1),1);
acNr1 = auctioneer; 
bidders = communicationCandidates(most_connected_agents_index(1), 2:end); 

highest_bidder = 0; 
current_bid = 0; 
increase = 1;
while increase ~= 0 && length(bidders) > 1
    increase = 0; 
    % Loop over active bidders
    for acNr2 = bidders
        step1b_routingSynchronizationFuelSavings
        % If bidder cannot afford to bid, remove from bidders list 
        if potentialFuelSavings <= 0 || potentialFuelSavings <= current_bid
             bidders = bidders(bidders~=acNr2); 
        else 
            side_auctioneer = determineAlliance(flightsData,...
                        nAircraft, acNr1);
            side_bidder = determineAlliance(flightsData, ...
                        nAircraft, acNr2);
            % Determine whether the bidder will increase bid
            % Bidder or auctioneer non-aliance
            if side_bidder == 1 || side_auctioneer == 1 
                limit = 0.5*potentialFuelSavings; 
                if current_bid > limit
                    bidders = bidders(bidders~=acNr2); 
                else
                    new_bid = min([limit ...
                        current_bid+0.1*(limit-current_bid)]);
                    increase = new_bid - current_bid;
                    current_bid = new_bid;
                    highest_bidder = acNr2;
                end 
            else %both alliance
                current_bid = potentialFuelSavings;
                highest_bidder = acNr2;
                increase = 1;
            end     
        end  
    end     
end     

if highest_bidder ~= 0
    acNr2 = highest_bidder; 
    step1b_routingSynchronizationFuelSavings
    fuelSavingsOffer = current_bid;
    divisionFutureSavings = flightsData(acNr1,19)/ ...
        (flightsData(acNr1,19) + flightsData(acNr2,19));
    % Update properties to accept the formation 
    step1c_updateProperties
end 
