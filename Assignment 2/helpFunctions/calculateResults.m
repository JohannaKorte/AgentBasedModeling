 function [fuelSavingsTotalPct,fuelSavingsAlliancePct, ...
    fuelSavingsNonAlliancePct,extraDistancePct,extraFlightTimePct, ...
    averageFormationSize, averageFormationNumbers, sameTypePct, ...
    allianceInFormationsPct_form, allianceInFormationsPct_all...
    divisionOfferManagerAverage, allianceManagerPI, auctionWinnerPI, ...
    winningBidPI, winningAllianceBidPI] = ...
    calculateResults(nAircraft,flightsDataRecordings,Wfinal,Vmax, ...
    fuelSavingsTotal,percentageAlliance, allianceManager, ...
    auctionWinners, winningBid, winningAllianceBid)
%% calculateResults.m description
% This function determines the realized fuel savings, the extra flight time
% due to formation flying, and the extra distance flown due to formation
% flying. It does this by first calculating the fuel consumption, flight
% distance, and flight time, if only solo flights were flown. Next, it
% calculates the actual fuel consumption, flight distance, and flight time,
% and compares the two.

% inputs: 
% nAircraft (number of real aircraft),
% flightsDataRecordings (flight data recorder that contains the flightsData
% at every time t),
% Wfinal (Zero Fuel Weight (ZFW) + Maximum Payload Weight of every aircraft
% after a complete solo flight [kg]),
% Vmax (Vmax [m/s]),
% fuelSavingsTotal (total fuel savings [kg]).

% outputs: 
% fuelSavingsTotalPct (percentual fuel savings, comparing the actual fuel
% use to the total fuel use if of only solo flights were flown),
% fuelSavingsAlliancePct (percentage of the total fuel savings that went to
% the alliance),
% fuelSavingsNonAlliancePct (percentage of the total fuel savings that went
% to the non-alliance flights),
% extraDistancePct (percentual change in total distance, comparing the
% actual total distance to the total distance if only solo flights were
% flown),
% extraFlightTimePct (percentual change in total flight, comparing the
% actual flight time to the total flight time of only solo flights were
% flown).

% added outputs
%

% special cases: 
% -

%% Calculate fuel consumption if all flights would have flown solo.

% Abbreviate flightsDataRecordings for shorter code.
FDR = flightsDataRecordings;
[runtimes, ~, ~] = size(FDR);

% Determine the solo route distances.
soloRouteDistances = [1:nAircraft ; sqrt((FDR(1,1:nAircraft,5)- ...
    FDR(1,1:nAircraft,3)).^2 + (FDR(1,1:nAircraft,6)- ...
    FDR(1,1:nAircraft,4)).^2)]';    
% Determine the fuel required for solo routes. Slot 23 (starting weight)
% has already been calculated in generateFlights.m. Wfinal is the ZFW +
% maximum payload weight.
soloFuelRequired = FDR(1,1:nAircraft,23) - Wfinal;                                                                % The solo fuel of each flight was already determined at the moment of generation
% Determine the flight time for solo routes.
soloFlightTimeSeconds = 1000.*soloRouteDistances(:,2)./Vmax;

%% Calculate extra distance and extra flight time for every flights.

% Predefine to later store actual mission length, and flight time for every
% flight.
missionLength = zeros(nAircraft,1);
formationFlightTimeSeconds = zeros(nAircraft,1);

% Calculate the extra distance and flight time for each flight separately.
for i = 1:nAircraft 
    % This clearing of variables ensures that the correct data is used for
    % every iteration.
    clearvars segment_lengths segmentendX segmentendY ...
        segments_node_coordinates_X segments_node_coordinates_Y
    
    % Determine the time steps t at which the heading or the M-value
    % changes.
    M_changes_at_t = find(abs(diff(FDR(:,i,8)))~=0 | ...
        abs(diff(FDR(:,i,13)))~=0)+1;  
    % Determine the coordinates of the flight at that time step.  
    segmentendX = FDR(M_changes_at_t,i,14);
    segmentendY = FDR(M_changes_at_t,i,15);
   
    % Store the nodes of each segment. The origin and current location have
    % to be added to the coordinate sets.
    segments_node_coordinates_X = [FDR(1,i,3);segmentendX;FDR(1,i,5)]; 
    segments_node_coordinates_Y = [FDR(1,i,4);segmentendY;FDR(1,i,6)];            
    
    % Determine the speeds after a heading change in order to obtain the
    % additional flight time.
    Speed_after_heading_change = FDR(M_changes_at_t,i,7);
    Speed_per_segment = [Vmax;Speed_after_heading_change];

    % These predefined vectors will temporarily hold information on one
    % flight. No need to store all data, just the results is faster.
    segment_lengths = zeros(length(segments_node_coordinates_X)-1,1); 
    segment_time_seconds = zeros(length(segments_node_coordinates_X)-1,1);                                               

    % Loop over the segments to determine the length and flight time at the
    % end of each segment.
    for l = 1:length(segments_node_coordinates_X)-1
        % Determine the length of each segment.
        segment_lengths(l) = sqrt((segments_node_coordinates_X(l+1) - ...
            segments_node_coordinates_X(l))^2 + ...
            (segments_node_coordinates_Y(l+1) - ...
            segments_node_coordinates_Y(l))^2);
        % Determine the time it takes to fly each segment.
        segment_time_seconds(l) = 1000.* ...
            segment_lengths(l)/Speed_per_segment(l);
    end

    % Determine the mission length.
    missionLength(i) = sum(segment_lengths);                 
    % Determine the flight time.
    formationFlightTimeSeconds(i) = sum(segment_time_seconds);
end

%% Calculate how much of the total fuel savings went to the alliance and non-alliance flights.

% This code calculates how much of the total fuel savings went to the
% alliance, and how much went to the non-alliance flights. It makes use of
% property 27 and 28.     

% Determine the total number of flights (including dummy flights).
nTotal = max(max(FDR(:,:,1)));
% Predefine the array for fuel savings per flight.
fuelSavingsPerFlight = zeros(nTotal,1);
% Loop backwards through all flight IDs (including dummy flights).
for i = nTotal:-1:1
    
    % Determine the time steps when flight i engaged to another flight,
    % based on property 27 (fuel savings [kg] flight i received from this
    % new formation).
    M_changes_at_t = find(abs(diff(FDR(:,i,27)))~=0)+1;
             
    % Check if flight i is a real flight or dummy flight.
    if i <= nAircraft
        % Check if flight i has engaged to other flight(s).
        if isempty(M_changes_at_t) ~= 1
            for j = 1:size(M_changes_at_t,1)
                % Add the fuel savings due to this new formation.
                fuelSavingsPerFlight(i) = fuelSavingsPerFlight(i) + ...
                    FDR(M_changes_at_t(j),i,27);
            end
        end
    % Enter this code block if flight i is a dummy flight and has engaged
    % to other flight(s). This distributes the fuel savings from dummy
    % flights over their real followers ultimately.
    elseif isempty(M_changes_at_t) ~= 1
        % Determine the two followers of flight i.
        flightsWithFlightI = find(FDR(M_changes_at_t(1),1:nTotal,22)==i);
        % Store the two flight IDs.
        acNr1 = flightsWithFlightI(1);
        acNr2 = flightsWithFlightI(2);
        % Loop through the time steps at which flight i forms a formation.
        for j = 1:size(M_changes_at_t,1) 
            % Store the time step for shorter code.
            timeStep = M_changes_at_t(j);
            % Distribute the fuel savings due to formations formed by
            % flight i over the followers of flight i.
            fuelSavingsPerFlight(acNr1) = fuelSavingsPerFlight(acNr1) + ...
                FDR(timeStep,i,27)*FDR(timeStep,acNr1,28);    
            fuelSavingsPerFlight(acNr2) = fuelSavingsPerFlight(acNr2) + ...
                FDR(timeStep,i,27)*FDR(timeStep,acNr2,28); 
        end
        % Distribute the total fuel savings that flight i collected from
        % its own formation leader(s) over the followers of flight i.
        fuelSavingsPerFlight(acNr1) = fuelSavingsPerFlight(acNr1) + ...
            fuelSavingsPerFlight(i)*FDR(timeStep,acNr1,28);
        fuelSavingsPerFlight(acNr2) = fuelSavingsPerFlight(acNr2) + ...
            fuelSavingsPerFlight(i)*FDR(timeStep,acNr2,28);
    end
end

%% Calculate the average amount and size of formations at every time t
%% as well as the percentage of same type formations
%InFormation makes a formation matrix, to see which aircraft are in which
%formation. Furthermore the average amount and size of formations can be 
% determined.  
form_alliance = zeros(nAircraft,1);
form_amount = zeros(runtimes,1);
form_size = zeros(runtimes,1);
sameType = [];
for r = 1:runtimes
    % find all non-zero elements, this is the ac this ac is following
    % row is the ac and v is the flight iD of the leading aircraft
    [~, ID , v] = find(FDR(r,:,22));
    ID = ID';
    formationAircraft = [ID v'];
    % Only make calculations if formations are formed
    % Making sure that you do not run it if only dummy aircraft are left
    if isempty(find(formationAircraft<nAircraft+1,1))~= 1
% If there are formations formed, then calculate size and amount
% if isempty(formationAircraft) ~= 1
        
        % Delete the dummy following aircraft 
        % Location of the following dummy
        followDummyLoc = find(formationAircraft(:,1)>nAircraft);      
        for i = 1:length(followDummyLoc)
            % flight ID of the following dummy and the leading dummy
            followDummy = formationAircraft(followDummyLoc(i),1);
            % flight ID of the leading dummy
            leadingDummy = formationAircraft(followDummyLoc(i),2);
            % Location(s) where follow dummy is leading dummy
            replaceTheDummy = find(formationAircraft(:,2)==followDummy);
            % replace them by the actual leading dummy
            formationAircraft(replaceTheDummy,2) = leadingDummy;
        end
        % remove the dummy following dummy row
        formationAircraft(followDummyLoc,:) = [];
        
        % put 1 or 2 in the list with the flight ID as order
        % (1 = non-alliance, 2 = alliance, 0 is not in a formation)
        form_alliance(formationAircraft(:,1)) = FDR(1,formationAircraft(:,1),25);
        
        % check which aircraft are leading aircraft
        leaders = unique(formationAircraft(:,2));

        % check the maximum size of the formations
        [~, F] = mode(formationAircraft(:,2));

        % make a matrix with first value is flight ID of leading aircraft 
        % the next values are the ID's of the following aircraft.
        formations = zeros(length(leaders), F+1);
        F_size = zeros(length(leaders),1);
        for j = 1:length(leaders)
            % location of the followers in the list per leader
            followerLoc = find(formationAircraft(:,2)==leaders(j));
            F_size(j) = length(followerLoc);
            formations(j,1:(F_size(j)+1)) = [leaders(j) formationAircraft(followerLoc,1).'];
            
            % SAMETYPE %
            % If the leader is not a member of the list yet, add to
            % sameType or not Same type
            if isempty(sameType) == 1 || ismember(leaders(j), sameType(:,1)) ~= 1
                % if all member of the formation are of the same type
                % give value 1, if not, give value 0
                if range(FDR(r,formations(j,2:1+F_size(j)),25))==0                    
                    sameType = [sameType; leaders(j) 1];
                else
                    sameType = [sameType; leaders(j) 0];  
                end    
            end  
             
        end
        
        % Used for output
        form_amount(r,1) = nnz(formations(:,1));
        form_size(r,1) = sum(F_size)./length(leaders);
        %end
    end    
end

% All offers (in percentage) to the manager, that the manager has chosen.
divisions = FDR(end,:,29);
%% Calulate results.

% Percentual change in total distance, comparing the actual total distance
% to the total distance if only solo flights were flown.
Total_solo_distance = sum(soloRouteDistances(:,2));
Total_covered_distance  = sum(missionLength);
extraDistancePct = (Total_covered_distance-Total_solo_distance)/ ...
    Total_solo_distance*100; 

% Percentual change in total flight, comparing the actual flight time to
% the total flight time of only solo flights were flown.
extraFlightTimePct = (sum(formationFlightTimeSeconds) - ...
    sum(soloFlightTimeSeconds))/sum(soloFlightTimeSeconds)*100;

% Percentual change in fuel use, comparing the actual fuel use to
% the total fuel use if of only solo flights were flown.
fuelSavingsTotalPct = fuelSavingsTotal/sum(soloFuelRequired)*100;

% Percentage of the total fuel savings that went to the alliance.
fuelSavingsAlliancePct = sum(fuelSavingsPerFlight(FDR(end,1:nAircraft,25)==2))/ ...
    fuelSavingsTotal*100;

% Percentage of the total fuel savings that went to the non-alliance
% flights.
fuelSavingsNonAlliancePct = sum(fuelSavingsPerFlight(FDR(end,1:nAircraft,25)==1))/ ...
    fuelSavingsTotal*100;

% Average size of formations per tick 
averageFormationSize = mean(form_size); % [-]

% Average amount of formations per tick
averageFormationNumbers = mean(form_amount); % [-]

% Percentage of same type aircraft formations
sameTypePct = mean(sameType(:,2))*100; % [%]

% Percentage of the alliance aircraft that make up all aircraft in formations
allianceInFormationsPct_form = numel(find(form_alliance==2))/nnz(form_alliance)...
    *100; % [%]

% Percentage of alliance aircraft in formations (wrt all alliance aircraft)
allianceInFormationsPct_all = numel(find(form_alliance==2))/(nAircraft*(percentageAlliance/100))...
    *100; % [%]

ticks = size(flightsDataRecordings,1);

% Average accepted offer from a manager (so how much does the manager get
% on average).
divisionOfferManagerAverage = sum(divisions)/nnz(divisions); % [-]

% Manager is alliance
allianceManagerPI = allianceManager/ticks*100; 

% Percentage of winning bids from alliance bidder 
auctionWinnerPI = auctionWinners/ticks*100; 

% Average heigt of winning bid
winningBidPI = winningBid/ticks;

% average height of winning alliance bid
winningAllianceBidPI = winningAllianceBid/ticks; 
end