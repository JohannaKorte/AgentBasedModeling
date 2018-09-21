% Main file for Assignment 1
% See README.txt for instructions

%_______PARAMETERS_________________________________________________________
xdim = 200;             %set x dimensions for simulation field 
ydim = 200;             %set y dimensions for simulation field
aircraft_count = 40;    %number of aircraft in the field 
max_velocity = 5;       %maximum velocity of the agent units/tick
min_velocity = 0.5;     %minimum velocity of the agent units/tick
separation_goal= 20;    %separation the agent aims to maintain
sight = 50;             %how far an agent can see
runs = 10;              %number of runs
ticks = 100;            %number of ticks per run
mode = 'proactive';     %'proactive' or 'reactive'
visualize = 1;          %1 (yes) or 0 (no)
%__________________________________________________________________________

conflicts = zeros(runs,ticks);
collisions = zeros(runs,ticks);

%run multiple runs as specified above
for r=1:runs 
    fprintf('Starting run %s\n', num2str(r));
    aircraft = AC.empty();  %initialize new AC class variable
    for i=1:aircraft_count
        aircraft(i)=AC(rand*xdim,rand*ydim,min_velocity, max_velocity, ...
            separation_goal, sight); 
    end

    a = Move(aircraft,[xdim ydim]); %Calculate movements of aircraft 
    if visualize
        f = figure;   %initialize new figure for simulation
        plane = Plane(f,[xdim ydim], aircraft); %Render image of aircraft
    end 
    results = a.run(plane, mode, ticks, visualize); %runs & draws the sim
    conflicts(r,:) = results(1,:); %stores number of collisions/conflicts
    collisions(r,:) = results(2,:);
    if visualize
        close(f);
    end
end 

% Plot conflict results 
figure;
title('Number of conflicts over time');
xlabel('Ticks');
ylabel('Number of conflicts');
yticks(linspace(0,aircraft_count, aircraft_count+1));
hold on
if runs > 1 
    %plot average of runs
    plot(mean(conflicts));
    fprintf('Average total number of conflicts from all runs: %s\n', ...
    num2str(sum(mean(conflicts))));
else 
    plot(conflicts(1,:))
    fprintf('Total number of conflicts during run: %s\n', ...
    num2str(sum(conflicts(1,:))));
end

%Plot collisions results
figure;
title('Number of collisions over time');
xlabel('Ticks');
ylabel('Number of collisions');
max_collisions = max(collisions(:));
hold on;
if runs > 1
%plot average of runs
    plot(mean(collisions))
    fprintf('Average total number of collisions from all runs: %s\n', ...
    num2str(sum(mean(collisions))));
else 
    plot(collisions(1,:))
    fprintf('Total number of collisions during run: %s\n', ... 
    num2str(sum(collisions(1,:))))
end

