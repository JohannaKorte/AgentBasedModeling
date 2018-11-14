function knowledge = communicateAllianceAuction(flightsData, bidders, ...
    auctioneer, nAircraft, wMulti, wTrail, Vmin, Vmax, dt, fuelPenalty, ...
    t, flightsDataRecordings, MFuelSolo, MFuelTrail)
    knowledge = [];
    % Loop over all bidders 
    for i=1:size(bidders,2)
        acNr1 = auctioneer; 
        acNr2 = bidders(i); 
        % If they are alliance, add their potentialFuelSavings to the
        % complete knowledge
        if determineAlliance(flightsData, nAircraft, acNr2) == 2 
            step1b_routingSynchronizationFuelSavings
            if potentialFuelSavings ~= 0
                knowledge = [knowledge ; acNr2 potentialFuelSavings];
            end 
        end 
    end 
end 