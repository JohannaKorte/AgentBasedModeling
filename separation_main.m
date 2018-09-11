% Main file for Assignment 1
xdim = 200;
ydim = 200; 
aircraft_count = 10;
max_velocity = 5; 

aircraft = AC.empty(); 
for i=1:aircraft_count
    aircraft(i)=AC(rand*xdim,rand*ydim,max_velocity);
end

a = Move(aircraft,[xdim ydim]);
f = figure;
plane = Plane(f,[xdim ydim], aircraft);
a.run(plane); %runs and draws the simulation