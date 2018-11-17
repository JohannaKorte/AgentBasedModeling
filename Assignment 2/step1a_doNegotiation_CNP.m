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
% row_number : is the row number of the highest bid in biddings
% offerToManager : bids to the manager
% betterOptions : three column array, first is the first and second are 
%                 flight ID's of alliance aircraft within communication range 
%                 that have a better fuel saving potential for the alliance. 
%                 This fuel savings is the third column 
% newmanager : empty if the previous manager did not choose a new manager,
%              otherwise it the flight ID of the new manager.

%% Loop through the combinations of flights that are allowed to communicate.
%%
%% There is coordination between alliance flights
if coordination == 1    

    % Determine the manager, it is the agent that is in contact with the most
    % other agents. If there is an equality, choose the first one.
    % Unless the previous manager choose the next
    % manager and that manager is part of the communicationCandidates.
    
    % Previous manager chose new manager
    if exist('newmanager') == 1 && isempty(newmanager)~=1 ...
                            && ismember(newmanager,communicationCandidates(:,1))
         % store flight ID of manager
         acNr1 = newmanager;
         % get all the communication candidates of the manager
         acnummer = find(communicationCandidates(:,1)==acNr1);
         nCandidates = nnz(communicationCandidates(acnummer,2:end));
         
    % The manager will be the one that is in contact with the most flights
    else
        communication_amount = zeros(length(communicationCandidates(:,1)),1);
        for i = 1:length(communicationCandidates(:,1))  
            % Determine the amount of nonzero elements per communucationCandid.
            communication_amount(i,1) = nnz(communicationCandidates(i,2:end));
        end
        [nCandidates, acnummer] = max(communication_amount);

        % Store flight ID of Manager
        acNr1 = communicationCandidates(acnummer,1);
    end
    % Put newmanager on empty again
    newmanager = 0;

    acNr1_original = acNr1; % will be used later on
    % Store agent type of manager
    acNr1_type = flightsData(acNr1,25);

    % Store all the bids in 'biddings'
    % biddings(j,1) = acNr2
    % biddings(j,2) = 2 (=alliance) or 1 (= Non-alliance) 
    %                (see currentProperty(:,25))
    % biddings(j,3) = division
    % biddings(j,4) = potentialFuelsavings*division
    biddings = zeros(nCandidates,4);

    % Loop over all candidates of flight i.
    betterOptions = [];
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
                biddings(j,2) = flightsData(acNr2,25);

                % Division depends on contractor
                % If manager and contractor are from the alliance (=2),
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
        % ADDED FOR COORDINATION
        % if j is alliance, search the other alliance he is in contact
        % with, safe potential fuel savings, if it is higher than its original bid.
        if acNr1_type == 2 && biddings(j,2)==2 && ismember(biddings(j,1),communicationCandidates(:,1))
            % find if he is in contact with other alliance aircraft
            % get all the communication candidates of the manager
            acnummer_alt = find(communicationCandidates(:,1)==biddings(j,1));
            nCandidates_alt = nnz(communicationCandidates(acnummer_alt,2:end));
            
            for x = 1:nCandidates_alt
                if flightsData(25,communicationCandidates(acnummer_alt,x))==2
                    acNr1 = biddings(j,1);
                    acNr2 = communicationCandidates(acnummer_alt,x);
                    step1b_routingSynchronizationFuelSavings
                    % If the potential fuel savings with another is bigger
                    % than with the current manager
                    if potentialFuelSavings > biddings(j,4)    
                        % store the potentialFuelSavings
                        betterOptions = [betterOptions;...
                            acNr1 acNr2 potentialFuelSavings];
                    end
                end
                
            end
        end
        acNr1 = acNr1_original;
    
    
    end
    % Store biddings in a table for readability
    biddings_table = array2table(biddings,...
        'VariableNames',{'FlightID','Type','Division','Bid'});

    %check if there are any biddings
    if nnz(biddings(:,4)) ~= 0
        % An alliance manager considers the fuel savings of all other alliance
        % aircraft around him
        if acNr1_type==2
            % Choose the winning option for the manager 
            [offerToManager, rownr_original] = max(biddings(:,4));
            if isempty(betteroptions) ~= 1
                [theBestOption, rownr_alternative] = max(betterOptions(:,3));
                if theBestOption > 1.3*offerToManager
                    %%% MANAGER CHOOSES NEW MANAGER %%%
                    newmanager = betterOptions(rownr_alternative,1);
                    % save how many times this option is used
                    if exist('useOfCoordinationAdvantage') == 0
                        useOfCoordinationAdvantage = 0;
                    end
                    useOfCoordinationAdvantage = useOfCoordinationAdvantage + 1;
                else
                    % An alliance manager considers the bidding of an alliance contractor
                    % twice as important as a bidding of a non-alliance contractor.
                    for j = 1:nCandidates
                        if biddings(j,2)==2
                            biddings(j,4) = biddings(j,4)*2;
                        end
                    end
                    % Choose the winning option for the manager 
                    [offerToManager, rownr_original] = max(biddings(:,4));
                    % If there are no better options, continue with the original
                    % winner.
                    % If the winning contractor is also alliance, set the
                    % fuelSavingsOffer back to the real offer and not the considered one.
                    if biddings(rownr_original,2) == 2
                        offerToManager = offerToManager/2;
                    end
                end
            end
        else
            % if manager is non-alliance
            % Choose the winning option for the manager 
            [offerToManager, rownr_original] = max(biddings(:,4)); 
        end
             
        % If there is no new manager chosen:
        if newmanager == 0
            fuelSavingsOffer = offerToManager;
            acNr2 = biddings(rownr_original,1);
            step1b_routingSynchronizationFuelSavings
            % In the CNP the value of divisionFutureSavings is decided upon by the 
            % contractor agent.
            divisionFutureSavings = biddings(rownr_original,3);
            flightsData(acNr1,29) = divisionFutureSavings;

            % Update the relevant flight properties for the formation
            % that is accepted.
            step1c_updateProperties
        end

    end

%% There is no coordidation between alliance flights
else
    
    communication_amount = zeros(length(communicationCandidates(:,1)),1);
    for i = 1:length(communicationCandidates(:,1))  
        % Determine the amount of nonzero elements per communucationCandid.
        communication_amount(i,1) = nnz(communicationCandidates(i,2:end));
    end
    [nCandidates, acnummer] = max(communication_amount);

    % Store flight ID of Manager
    acNr1 = communicationCandidates(acnummer,1);
    % Store agent type of manager
    acNr1_type = flightsData(acNr1,25);

    % Store all the bids in 'biddings'
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
                biddings(j,2) = flightsData(acNr2,25);
                % Division depends on contractor
                % If manager and contractor are from the alliance (=2),
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
        % If the manager and winning contractor are both alliance, set the
        % fuelSavingsOffer back to the real offer and not the considered one.
        if biddings(row_number,2) == 2 && acNr1_type == 2
            fuelSavingsOffer = fuelSavingsOffer/2;
        end
        acNr2 = biddings(row_number,1); 
        step1b_routingSynchronizationFuelSavings
        % In the CNP the value of divisionFutureSavings is decided upon by the 
        % contractor agent.
        divisionFutureSavings = biddings(row_number,3);
        flightsData(acNr1,29) = divisionFutureSavings;

        % Update the relevant flight properties for the formation
        % that is accepted.
        step1c_updateProperties
    end
end

    
    

