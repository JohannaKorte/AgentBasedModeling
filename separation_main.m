% Main file for Assignment 1
xdim = 200; %set dimensions for field 
ydim = 200; 
aircraft_count = 40;    %number of aircraft in the field 
max_velocity = 1;       %maximum velocity of the aircraft 
sight = 50;             %how far an agent can see

aircraft = AC.empty();  %initialize new AC class variable
for i=1:aircraft_count
    aircraft(i)=AC(rand*xdim,rand*ydim,max_velocity, sight, rand); %initialize  
end
 
a = Move(aircraft,[xdim ydim]); %Calculate movements of aircraft 
f = figure;   %initialize new figure
plane = Plane(f,[xdim ydim], aircraft); %Render image of aircraft
a.run(plane); %runs and draws the simulation