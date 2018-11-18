%% final3_concludeSimulation.m description
% This file calculates the realized fuel savings (percentual and absolute),
% the extra flight time due to formation flying, and the extra distance
% flown due to formation flying. Some additional performance indicators are
% calculated in this file.

% It contains one function: calculateResults.m.

%% Concluding data.

% This function determines the realized fuel savings, the extra flight time
% due to formation flying, and the extra distance flown due to formation
% flying.

[fuelSavingsTotalPct,fuelSavingsAlliancePct, ...
fuelSavingsNonAlliancePct,extraDistancePct,extraFlightTimePct, ...
averageFormationSize, averageFormationNumbers, sameTypePct, ...
allianceInFormationsPct_form, allianceInFormationsPct_all...
divisionOfferManagerAverage] = ...
    calculateResults(nAircraft,flightsDataRecordings,Wfinal,Vmax, ...
    fuelSavingsTotal,percentageAlliance);

% Actual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
%1
fuelSavingsTotalPerRun(simrun) = fuelSavingsTotal; % [kg]

% Percentual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
%2
fuelSavingsTotalPctPerRun(simrun) = fuelSavingsTotalPct; % [%]

% Percentage of the total fuel savings that went to the alliance.
%3
fuelSavingsAlliancePctPerRun(simrun) = fuelSavingsAlliancePct; % [%]

% Percentage of the total fuel savings that went to the non-alliance
% flights.
%4
fuelSavingsNonAlliancePctPerRun(simrun) = fuelSavingsNonAlliancePct; % [%]

% Percentual change in total distance, comparing the actual total distance
% to the total distance if only solo flights were flown.
%5
extraDistancePctPerRun(simrun) = extraDistancePct; % [%]

% Percentual change in total flight, comparing the actual flight time to
% the total flight time of only solo flights were flown.
%6
extraFlightTimePctPerRun(simrun) = extraFlightTimePct; % [%]

% ADDED
% Average size of formations per tick per run
% 7
averageFormationSizePerRun(simrun) = averageFormationSize; % [-]

% ADDED
% Average amount of formations per tick per run
%8
averageFormationNumbersPerRun(simrun) = averageFormationNumbers; % [-]

% ADDED
% Percentage of same type (alliance/non-alliance) aircraft formations per run
% 9
sameTypePctPerRun(simrun) = sameTypePct; % [%]

% ADDED
% Percentage of the alliance aircraft that make up all aircraft in
% formations Per run
% 10 
allianceInFormationsPctPerRun_form(simrun) = allianceInFormationsPct_form; % [%]

% ADDED
% Percentage of alliance aircraft in formations (wrt all alliance aircraft)
% Per run
% 11
allianceInFormationsPctPerRun_all(simrun) = allianceInFormationsPct_all; % [%]

% ADDED
% Average accepted offer from a manager (so how much does the manager get
% on average) per run.
% 12
divisionOfferManagerAveragePerRun(simrun) = divisionOfferManagerAverage; % [-]

if coordination == 1
% The amount of times there has been made use of the coordination advantage
% of the alliance manager.
useOfCoordinationAdvantagePerRun(simrun) = useOfCoordinationAdvantage; % [-]
clearvars useOfCoordinationAdvantage
end

results = [fuelSavingsTotalPerRun'; fuelSavingsTotalPctPerRun'; ...
    fuelSavingsAlliancePctPerRun'; fuelSavingsNonAlliancePctPerRun';...
    extraDistancePctPerRun'; extraFlightTimePctPerRun'; ...
    averageFormationSizePerRun'; averageFormationNumbersPerRun'; ...
    sameTypePctPerRun'; allianceInFormationsPctPerRun_form'; ...
    allianceInFormationsPctPerRun_all'; divisionOfferManagerAveragePerRun'];
%% Clear some variables.

clearvars a acNr1 acNr2 c communicationCandidates divisionFutureSavings ...
    flightIDsFollowers flightsArrived flightsAtCurrentLocation ...
    flightsDeparted flightsNotMovedYet flightsOvershot followersOfFlightA ...
    fuelSavingsOffer i j m n nCandidates potentialFuelSavings s ...
    syncPossible timeAdded_acNr1 timeAdded_acNr2 timeWithinLimits ...
    travelledDistance travelledDistanceX travelledDistanceY ...
    uniqueFormationCurrentLocations VsegmentAJ_acNr1 VsegmentBJ_acNr2 ...
    wAC wBD wDuo Xjoining Xordes Xsplitting Yjoining Yordes Ysplitting ...
    extraDistancePct extraFlightTimePct fuelSavingsAlliancePct ...
    fuelSavingsNonAlliancePct fuelSavingsTotal fuelSavingsTotalPct ...
    averageFormationSize averageFormationNumbers sameTypePct ...
    allianceInFormationsPct_form allianceInFormationsPct_all ...
    divisionOfferManagerAverage