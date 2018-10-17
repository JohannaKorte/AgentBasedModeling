function alliance_indicator = determineAlliance(flightsData,nAc, id)
    if flightsData(id, 25) == 1
        alliance_indicator = 1;
    elseif flightsData(id, 25) == 2
        alliance_indicator = 2; 
    %Formation    
    elseif flightsData(id, 25) == 0
        %Determine leader and recurse 
        flightsAtCurrentLocation = find(flightsData(1:nAc,14)== ...
            flightsData(id,14) & flightsData(1:nAc,15)== ...
            flightsData(id,15)); 
        leader = min(flightsAtCurrentLocation);
        alliance_indicator = determineAlliance(flightsData,nAc,leader);
    end     
end 