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

%% NEW/CHANGED VARIABLES
%%
% communication_amount : amount of agents a potential contractor is in
%                        contact with.
% nCadidates : the maximum amount of agents another agent is in contact with.
% acnummer : the aircraft number of the agent with max_com
% biddings : stores all the biddings from all contractors to acNr1.
%            First column is acNr2, second is the bid of that acNr2.
% division : stores the way all contractors want to divide the fuelsaving.
% NOT REALLY USED ATM
% row_number : is the row number of the highest bid in biddings
% contractor : is the contractor chosen (the one with the highest bid)
%%
%% Loop through the combinations of flights that are allowed to communicate.
% Determine the manager, it is the agent that is in contact with the most
% other agents. If there is an equality, choose the first one.
communication_amount = zeros(length(communicationCandidates(:,1)),1);
for i = 1:length(communicationCandidates(:,1))  
    % Determine the amount of nonzero elements per communucationCandid.
    communication_amount(i,1) = nnz(communicationCandidates(i,2:end));
end
[nCandidates, acnummer] = max(communication_amount);

% Store flight ID of Manager
acNr1 = communicationCandidates(acnummer,1);
% Store agent type of manager
acNr1_type = determineAlliance(flightsData, nAircraft, acNr1);

% Store all the bidding in 'biddings'
% biddings(j,1) = acNr2
% biddings(j,2) = 2 (=alliance) or 1 (= Non-alliance) 
%                (see currentProperty(:,25))
% biddings(j,3) = division
% biddings(j,4) = potentialFuelsavings*division
biddings = zeros(nCandidates,4);

% Loop over all candidates of flight i.
for j = 1:nCandidates
    % Store flight ID of candidate flight j in variable.
    acNr2 = communicationCandidates(acnummer,j+1); 
        
    % Check whether the flights are still available for communication.
    if flightsData(acNr1,2) == 1 && flightsData(acNr2,2) == 1             
        % This file contains code to perform the routing and
        % synchronization, and to determine the potential fuel savings.
        step1b_routingSynchronizationFuelSavings

        % If the involved flights can reduce their cumulative fuel burn
        % the formation route is stored.
        if potentialFuelSavings > 0    
            % store acnumber and if alliance or not
            biddings(j,1) = acNr2;
            biddings(j,2) = determineAlliance(flightsData, nAircraft,...
                acNr2);
            % Division depends on contractor
            % If manager and contractor are from the alliance,
            % then contractor gives the full 100%.
            % else, bid 50%
            if biddings(j,2)==2 && acNr1_type==2
                biddings(j,3) = flightsData(acNr1,19);
            else
                biddings(j,3) = flightsData(acNr1,19)/ ...
                (flightsData(acNr1,19) + flightsData(acNr2,19));
            end
            % store all the bids
            biddings(j,4) = potentialFuelSavings*biddings(j,3); 
        end
    end
end
% Store biddings in a table for readability
biddings_table = array2table(biddings,...
    'VariableNames',{'FlightID','Type','Division','Bid'});
%check if there are any biddings
if nnz(biddings(:,4)) ~= 0
    % An alliance manager considers the bidding of an alliance contractor
    % twice as important as a bidding of a non-alliance contractor.
    for j = 1:nCandidates
        if biddings(j,2)==2 && acNr1_type==2
            biddings(j,4) = biddings(j,4)*2;
        end
    end
    % Chose the winning contractor
    [fuelSavingsOffer, row_number] = max(biddings(:,4)); 
    acNr2 = biddings(row_number,1); 
    step1b_routingSynchronizationFuelSavings
    % In the CNP the value of divisionFutureSavings is decided upon by the 
    % contractor agent.
    if biddings(row_number,2)== 2
       fuelSavingsOffer = biddings(j,4)/2; 
    end
    divisionFutureSavings = flightsData(acNr1,19)/ ...
        (flightsData(acNr1,19) + flightsData(acNr2,19));

    % Update the relevant flight properties for the formation
    % that is accepted.
    step1c_updateProperties

end
