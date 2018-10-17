% step1a_doNegotiation_Dutch.m description
% Add your Dutch agent models and edit this file to create your Dutch
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

% Step size to decrease the auction bid by 
decreaseBid = 20; 

% Find the agent that can communicate with most others and choose it as an
% agent
most_connected_agents_index = find(communicationCandidates(:,end));
% Pick first index to be auctioneer
auctioneer = communicationCandidates(most_connected_agents_index(1),1);
acNr1 = auctioneer; 
bidders = communicationCandidates(most_connected_agents_index(1), 2:end); 

% Start with a high current_bid, and decrease it until a bidder wants to 
% take the bid
% Bid = kg of fuel that the manager will receive  
accepted_bid = 'false';
current_bid = 1000; %highest fuel savings 
while strcmp(accepted_bid,'false')
    if current_bid >= 0 + decreaseBid %ensure feasible bid
        current_bid = current_bid - decreaseBid;
        for acNr2 = bidders
            % Check if auctioneer and bidder can still communicate
            if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1
                step1b_routingSynchronizationFuelSavings %calculate savings
                % Can acNr2 take the bid?
                if 0 < potentialFuelSavings && ...
                        potentialFuelSavings >= current_bid
                    % Determine limit under which will accept
                    % If auctioneer or bidder non-alliance 50/50
                    % If both alliance 100%
                    side_auctioneer = determineAlliance(flightsData,...
                        nAircraft, acNr1);
                    side_bidder = determineAlliance(flightsData, ...
                        nAircraft, acNr2);
                    if side_auctioneer == 1 || side_bidder == 1
                        limit = 0.5*potentialFuelSavings; 
                    else
                        limit = potentialFuelSavings; 
                    end 
                    
                    % Check if bidder wants to take the bid 
                    if current_bid <= limit
                        fuelSavingsOffer = current_bid;
                        divisionFutureSavings = flightsData(acNr1,19)/ ...
                            (flightsData(acNr1,19) + flightsData(acNr2,19));
                        % Update properties to accept the formation 
                        step1c_updateProperties
                        accepted_bid = 'true'; 
                    end 
                end 
            end 
        end
    else
        break; 
    end
end    
