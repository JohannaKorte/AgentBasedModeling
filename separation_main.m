% Main file for Assignment 1
xdim = 200;
ydim = 200; 
aircraft_count = 40;

aircraft = AC.empty(); %TODO: Create AC class
for i=1:aircraft_count
   aircraft(i)=AC(rand*xdim,rand*ydim);
end

%TODO: Calculate actions
%TODO: Create figure
%TODO: Create Plane using Plane from boids
%TODO: Run and draw calculated actions
