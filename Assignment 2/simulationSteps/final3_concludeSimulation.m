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
allianceInFormationsPct_form, allianceInFormationsPct_all] = ...
    calculateResults(nAircraft,flightsDataRecordings,Wfinal,Vmax, ...
    fuelSavingsTotal,percentageAlliance);

% Actual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
fuelSavingsTotalPerRun(simrun) = fuelSavingsTotal; % [kg]

% Percentual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
fuelSavingsTotalPctPerRun(simrun) = fuelSavingsTotalPct; % [%]

% Percentage of the total fuel savings that went to the alliance.
fuelSavingsAlliancePctPerRun(simrun) = fuelSavingsAlliancePct; % [%]

% Percentage of the total fuel savings that went to the non-alliance
% flights.
fuelSavingsNonAlliancePctPerRun(simrun) = fuelSavingsNonAlliancePct; % [%]

% Percentual change in total distance, comparing the actual total distance
% to the total distance if only solo flights were flown.
extraDistancePctPerRun(simrun) = extraDistancePct; % [%]

% Percentual change in total flight, comparing the actual flight time to
% the total flight time of only solo flights were flown.
extraFlightTimePctPerRun(simrun) = extraFlightTimePct; % [%]

% Average size of formations per tick per run
averageFormationSizePerRun(simrun) = averageFormationSize; % [-]

% Average amount of formations per tick per run
averageFormationNumbersPerRun(simrun) = averageFormationNumbers; % [-]

% Percentage of same type (alliance/non-alliance) aircraft formations per run
sameTypePctPerRun(simrun) = sameTypePct; % [%]

% Percentage of the alliance aircraft that make up all aircraft in
% formations Per run
allianceInFormationsPctPerRun_form(simrun) = allianceInFormationsPct_form; % [%]

% Percentage of alliance aircraft in formations (wrt all alliance aircraft)
% Per run
allianceInFormationsPctPerRun_all(simrun) = allianceInFormationsPct_all; % [%]
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
    allianceInFormationsPct_form allianceInFormationsPct_all