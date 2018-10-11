%% step1a_doNegotiation_CNP.m description
% Add your CNP agent models and edit this file to create your CNP. 

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

%% Loop through the combinations of flights that are allowed to communicate.
communication_amount = zeros(length(communicationCandidates(:,1)),1);
for i = 1:length(communicationCandidates(:,1))  
    % Determine the amount of nonzero elements per communucationCandid.
    communication_amount(i,1) = nnz(communicationCandidates(i,2:end));
end
[max_com, acnummer] = max(communication_amount);

% Store flight ID of Manager
acNr1 = communicationCandidates(acnummer,1);   

% Determine the number of communication candidates for flight i.
nCandidates = max_com;
% Loop over all candidates of flight i.
for j = 2:nCandidates+1
    % Store flight ID of candidate flight j in variable.
    acNr2 = communicationCandidates(acnummer,j);  

    % Check whether the flights are still available for communication.
    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1             
        % This file contains code to perform the routing and
        % synchronization, and to determine the potential fuel savings.
        step1b_routingSynchronizationFuelSavings

        % Store all the bidding in 'biddings'
        % biddings(j,1) = acNr2
        % biddings(j,2) = potentialFuelsavings*division
        biddings = zeros(j,2);

        % If the involved flights can reduce their cumulative fuel burn
        % the formation route is stored.
        if potentialFuelSavings > 0    
            % For now divide 50-50,but should depend on the contractor.
            division = flightsData(acNr1,19)/ ...
                (flightsData(acNr1,19) + flightsData(acNr2,19));
            % store all the bids
            biddings(j,1) = acNr2;
            biddings(j,2) = potentialFuelSavings*division; 
        end
    end
end
% Chose the winning contractor
[fuelSavingsOffer, row_number] = max(bidings(:,2)); 
acNr2 = biddings(row_number,1);

% In the CNP the value of divisionFutureSavings is decided upon by the 
% contractor agent.
divisionFutureSavings = flightsData(acNr1,19)/ ...
    (flightsData(acNr1,19) + flightsData(acNr2,19));

% Update the relevant flight properties for the formation
% that is accepted.
step1c_updateProperties