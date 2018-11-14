% step1a_doNegotiation_Japanese.m description
% Add your Japanese agent models and edit this file to create your Japanese
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

% Step size to increase the auction bid by 
increaseBid = 20; 

% Find the agent that can communicate with most others and choose it as a
% auctioneer
most_connected_agents_index = find(communicationCandidates(:,end));
% Pick first index to be auctioneer
auctioneer = communicationCandidates(most_connected_agents_index(1),1);
acNr1 = auctioneer; 
bidders = communicationCandidates(most_connected_agents_index(1), 2:end); 

% Start with current_bid of 0, and increase it. When the personal limit is
% reached for a bidder, it exits the auction. The last bidder left takes
% the bid. 

current_bid = 1; 

if communication == 1  %communication/coordination allowed 
    allKnowledge = communicateAllianceAuction(flightsData, bidders, ...
        auctioneer, nAircraft, wMulti, wTrail, Vmin, Vmax, dt, ...
        fuelPenalty, t, flightsDataRecordings, MFuelSolo, MFuelTrail);
    side_auctioneer = determineAlliance(flightsData, nAircraft, acNr1);

    while length(bidders) > 1
        %loop over bidders to see if anyone wants to exit
        for acNr2 = bidders
            knowledge = [];
            step1b_routingSynchronizationFuelSavings
            side_bidder = determineAlliance(flightsData,nAircraft, acNr2);
            % Determine knowledge 
            if side_auctioneer == 1 && side_bidder == 2
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
            elseif side_auctioneer == 2 && side_bidder == 2
                % auctioneer and bidder are alliance
                knowledge = allKnowledge;
            end
            
            % If bidder cannot stay, remove from bidders list 
            if potentialFuelSavings <= 0 || potentialFuelSavings < current_bid
                bidders = bidders(bidders~=acNr2); 
                break
            end 

            % If bidder does not want to stay, remove from bidders list
            if side_bidder == 1
                % bidder is non-alliance
                if 0.5*potentialFuelSavings < current_bid
                    bidders = bidders(bidders~=acNr2); 
                    break
                end 
            elseif side_auctioneer == 1
                % bidder is alliance, but auctioneer is not
                if 0.5*potentialFuelSavings < current_bid
                    bidders = bidders(bidders~=acNr2); 
                    break
                end 
            else 
                % bidder and auctioneer alliance
                if ~isempty(knowledge) && max(knowledge(:,2) > ...
                        potentialFuelSavings)
                    bidders = bidders(bidders~=acNr2); 
                    break
                end 
            end  
        end 
        current_bid = current_bid + increaseBid;
    end
else  % No communication/coordination allowed between alliance flights 
    while length(bidders) > 1
        %loop over bidders to see if anyone wants to exit
        for acNr2 = bidders
            step1b_routingSynchronizationFuelSavings
            % If bidder cannot stay, remove from bidders list 
            if potentialFuelSavings <= 0 || potentialFuelSavings < current_bid
                bidders = bidders(bidders~=acNr2); 
                break
            end 
            % If bidder does not want to stay, remove from bidders list
            side_auctioneer = determineAlliance(flightsData,...
                            nAircraft, acNr1);
            side_bidder = determineAlliance(flightsData, ...
                            nAircraft, acNr2);
            if side_auctioneer == 1 || side_bidder == 1
               if 0.5*potentialFuelSavings < current_bid
                    bidders = bidders(bidders~=acNr2); 
                    break
               end 
            end           
        end 
        current_bid = current_bid + increaseBid;
    end
end

if length(bidders) == 1 && current_bid ~=0
    acNr2 = bidders(1);
    step1b_routingSynchronizationFuelSavings
    if potentialFuelSavings ~= 0
        fuelSavingsOffer = current_bid;
        divisionFutureSavings = flightsData(acNr1,19)/ ...
            (flightsData(acNr1,19) + flightsData(acNr2,19));
        % Update properties to accept the formation
        step1c_updateProperties
    end 
end 

