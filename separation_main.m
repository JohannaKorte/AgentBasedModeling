% Main file for Assignment 1

%_______PARAMETERS_________________________________________________________
xdim = 200;             %set dimensions for field 
ydim = 200; 
aircraft_count = 40;    %number of aircraft in the field 
max_velocity = 3;       %maximum velocity of the aircraft 
sight = 50;             %how far an agent can see
runs = 2;               %number of runs
ticks = 10;             %number of ticks per run
mode = 'proactive';     %'proactive' or 'reactive'
visualize = 1;          %1 (yes) or 0 (no)
%__________________________________________________________________________

conflicts = zeros(runs,ticks);
collisions = zeros(runs,ticks);

%run multiple runs as specified above
for r=1:runs 
    aircraft = AC.empty();  %initialize new AC class variable
    for i=1:aircraft_count
        aircraft(i)=AC(rand*xdim,rand*ydim,max_velocity, sight); 
    end

    a = Move(aircraft,[xdim ydim]); %Calculate movements of aircraft 
    f = figure;   %initialize new figure for simulation
    plane = Plane(f,[xdim ydim], aircraft); %Render image of aircraft
    results = a.run(plane, mode, ticks); %runs and draws the simulation
    conflicts(r,:) = results(1,:); %stores number of collisions/conflicts
    collisions(r,:) = results(2,:);
    close(f);
end 

% Plot conflict results 
figure;
title('Number of conflicts over time');
xlabel('Ticks');
ylabel('Number of conflicts');
hold on
for ii = 1:runs
 plot(conflicts(ii,:))
end

%Plot collisions results
figure;
title('Number of collisions over time');
xlabel('Ticks');
ylabel('Number of collisions');
hold on 
for ii = 1:runs
 plot(collisions(ii,:))
end