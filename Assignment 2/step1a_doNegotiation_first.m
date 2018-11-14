% step1a_doNegotiation_first.m description
% Add your first-price sealed-bid agent models and edit this file to create
% your first-price sealed-bid auction.

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
highest_bid = 0; 
highest_bidder = 0;

if communication == 1  % Communication between alliance flights
    % Determine whether the auctioneer is alliance, if so share all its 
    % knowledge of maximum fuel savings with all other alliance flights
    side_auctioneer = determineAlliance(flightsData, nAircraft, acNr1);
    allKnowledge = communicateAllianceAuction(flightsData, bidders, ...
        auctioneer, nAircraft, wMulti, wTrail, Vmin, Vmax, dt, ...
        fuelPenalty, t, flightsDataRecordings, MFuelSolo, MFuelTrail);
    knowledge = [];
    for acNr2 = bidders
        if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1
            % Calculate possible savings of this agent/auctioneer
            % combination
            step1b_routingSynchronizationFuelSavings
            side_bidder = determineAlliance(flightsData, nAircraft, acNr2);
            
            % Determine the knowledge obtained by communication 
            if side_auctioneer == 1
                % only knowledge of agents in my communication range
                % because auctioneer is not alliance
                nearbyAgents = communicationCandidates(...
                    communicationCandidates(:,1)==acNr2, 2:end);
                for b=nearbyAgents
                    if ~isempty(allKnowledge)
                        pfs = allKnowledge(allKnowledge(:,1)==b, :); 
                        if ~isempty(pfs)
                            knowledge = [knowledge; b pfs]; 
                        end 
                    end 
                end 
            elseif side_auctioneer == 2
                % auctioneer and bidder are alliance
                knowledge = allKnowledge;
            end
            
            % Determine bid 
            if side_bidder == 1
                % bidder is not alliance 
                bid = 0.5*potentialFuelSavings;
            elseif side_auctioneer == 1
                % bidder is alliance, but auctioneer is not
                % strategy: only highest alliance in communication range 
                % will bid their maximum of 0.5*fuelsavings
                if size(knowledge) > 0
                    if max(knowledge) <= potentialFuelSavings
                        bid = 0.5*potentialFuelSavings; 
                    else 
                        bid = 0; 
                    end
                else
                    bid = 0.5*potentialFuelSavings; 
                end 
            else 
                % bidder and auctioneer are alliance
                if size(knowledge) > 0
                    if max(knowledge) <= potentialFuelSavings
                        bid = potentialFuelSavings; 
                    else 
                        bid = 0; 
                    end
                else     
                    bid = potentialFuelSavings;
                end 
            end 
            
            %Update highest bid
            if bid > 0 && bid > highest_bid
                highest_bid = bid; 
                highest_bidder = acNr2;
            end 
        end 
    end 
else %No communication between alliance flights
    %Loop over bidders
    for acNr2 = bidders
        if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1
            %Calculate possible savings
            step1b_routingSynchronizationFuelSavings
            %Determine bid 
            side_auctioneer = determineAlliance(flightsData, nAircraft, acNr1);
            side_bidder = determineAlliance(flightsData, nAircraft, acNr2);
            if side_bidder == 1 || side_auctioneer == 1
                bid = min([0.5*potentialFuelSavings potentialFuelSavings]);
            else 
                bid = potentialFuelSavings; 
            end 
            %Update highest bid
            if bid > 0 && bid > highest_bid
                highest_bid = bid; 
                highest_bidder = acNr2;
            end 
        end 
    end 
end 

if highest_bid > 0 
    acNr2 = highest_bidder; 
    step1b_routingSynchronizationFuelSavings
    % Adjust bid to highest bid
    fuelSavingsOffer = highest_bid;
    divisionFutureSavings = flightsData(acNr1,19)/ ...
        (flightsData(acNr1,19) + flightsData(acNr2,19));
    % Update properties to accept the formation 
    step1c_updateProperties
end 