%% prep3_performanceIndicators.m description
% This file predefines the variables that will be used to track performance
% indicators over the simulation runs.

% Add the code for your own performance indicators to this file. 

%% Performance indicators.

% Actual fuel savings, comparing the actual fuel use to the total fuel use
% if of only solo flights were flown.
fuelSavingsTotalPerRun = zeros(nSimulations,1); % [kg]

% Percentual fuel savings, comparing the actual fuel use to the total fuel
% use if of only solo flights were flown.
fuelSavingsTotalPctPerRun = zeros(nSimulations,1); % [%]

% Percentage of the total fuel savings that went to the alliance.
fuelSavingsAlliancePctPerRun = zeros(nSimulations,1); % [%] 

% Percentage of the total fuel savings that went to the non-alliance
% flights.
fuelSavingsNonAlliancePctPerRun = zeros(nSimulations,1); % [%] 

% Percentual change in total distance, comparing the actual total distance
% to the total distance if only solo flights were flown.
extraDistancePctPerRun = zeros(nSimulations,1); % [%]

% Percentual change in total flight, comparing the actual flight time to
% the total flight time of only solo flights were flown.
extraFlightTimePctPerRun = zeros(nSimulations,1); % [%]  

% Average size of formations per tick per run
averageFormationSizePerRun = zeros(nSimulations,1); % [-]

% Average amount of formations per tick per run
averageFormationNumbersPerRun = zeros(nSimulations,1); % [-]

% Percentage of same type (alliance/non-alliance) aircraft formations per run
sameTypePctPerRun = zeros(nSimulations,1); % [%]

% Percentage of the alliance aircraft that make up all aircraft in
% formations Per run
allianceInFormationsPctPerRun_form = zeros(nSimulations,1); % [%]

% Percentage of alliance aircraft in formations (wrt all alliance aircraft)
% Per run
allianceInFormationsPctPerRun_all = zeros(nSimulations,1); % [%]

% Average accepted offer from a manager (so how much does the manager get
% on average) per run.
divisionOfferManagerAveragePerRun = zeros(nSimulations,1); % [-]

% The amount of times there has been made use of the coordination advantage
% of the alliance manager.
useOfCoordinationAdvantagePerRun = zeros(nSimulations,1); % [-]

% The percentage of auctions with an alliance auctioneer per run
allianceAuctioneersPctPerRun = zeros(nSimulations,1); % [%]
allianceManager = 0; 

% The percentage of auctions that is won by an alliance bidder per run
auctionWinnersAlliancePctPerRun = zeros(nSimulations,1); % [%]

% The average winning bid per run
averageWinningBidPerRun = zeros(nSimulations,1); % [kg]

% The average winning alliance bid per run
averageWinningAllianceBidPerRun = zeros(nSimulations,1); % [kg]
