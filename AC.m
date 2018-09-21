classdef AC
    % AC   Summary of AC
    % This class is meant for initializing aircraft agents and functions
    % that can be applied to these agents
    %
    % AC properties:
    %   angle           - The agents angle in radials
    %   position        - The agents [x, y] position
    %   velocity        - The agent's speed as [x speed, yspeed]
    %   min_velocity    - The agent's minimum speed
    %   max_velocity    - The agent's maximum speed
    %   sep_goal        - The amount of separation an agent aims to keep
    %   r               - How far an agent can fly past the lattice until 
    %                    it will come back on the other side 
    %   sight           - How far the agent is able to see around himself
    %
    % AC Methods:
    %   AC              - Initialize new AC instance
    %   move            - Calculates new velocity by calling functions
    %   update          - Move the agent one step forward
    %   borders         - Makes sure the borders of the lattice wrap around
    %   reactive        - Implements a reactive strategy
    %   proactive       - Calls proactive_move
    %   proactive_move  - Imiplements a proactive strategy
    %   resume_speed    - Increases speed to max_speed, maintains angle
    %   distance        - Calculates distance between two agents
    %   density_turn    - Makes a turn based on closest agent
    %   speeddown       - Slows down agent
    %   speedup         - Speeds up agent
    %   turn            - Turns agent specified amount of degrees
    %   sameheading     - Checks if two agents have similar headings
    %   oppositeheading - Checks if two agents have opposite headings
    %   sideheading     - Checks if two agents have side headings
    %   front           - Checks if one agent is in front of another
    %   count_conflicts - Counts number of conflicts between all aircraft
    
    properties 
       angle 
       position
       velocity
       min_velocity
       max_velocity
       sep_goal
       r
       sight
       previous_pos
    end
    
    methods 
        function obj = AC(xpos, ypos, minv, maxv, sep_goal, sight) 
            % Initializes a new aircraft agent with an initial angle
            % position, speed and the maximum speed.
            obj.angle = (2*pi).*rand;
            obj.position = [xpos ypos];
            obj.velocity = [cos(obj.angle) sin(obj.angle)];
            obj.min_velocity = minv; 
            obj.max_velocity = maxv;
            obj.sep_goal = sep_goal;
            obj.r = 0;  %Space around the square that needs to be traversed
            %before coming out again on the other side.
            obj.sight = sight; 
        end
   
        function obj = move(obj,aircraft)
            % Call functions that will ensure separation
            obj.velocity = obj.reactive(aircraft); 
        end
        
        function obj = update(obj)
            % Make the agent move one step into its desired direction by
            % updating its position using the velocity attribute
            obj.previous_pos(1) = obj.position(1);
            obj.previous_pos(2) = obj.position(2);
            obj.position = obj.position + obj.velocity;
        end
        
        function obj = borders(obj, lattice_size)
            % Makes sure that the aircraft cannot fall of the grid, by 
            % connecting opposite sides to eachother.
            if obj.position(1) < -obj.r 
                obj.position(1)=lattice_size(1)+obj.r; 
            end
            
            if obj.position(2) < -obj.r 
                obj.position(2)=lattice_size(2)+obj.r; 
            end
            
            if obj.position(1) > lattice_size(1) + obj.r 
                obj.position(1)=-obj.r;     
            end
            
            if obj.position(2) > lattice_size(2) + obj.r
                obj.position(2)=-obj.r;    
            end
        end 
        
        function [velocity] = reactive(obj, ac)
            num_aircraft = size(ac,2);
            d = zeros(1,num_aircraft);
            for i = 1:num_aircraft
                velocity = obj.velocity;
                v = velocity; 
              
                % Find distances to other aircraft position(1) is x
                % position(2) is y coordinate
                d(1,i) = pdist([obj.position(1), obj.position(2); 
                ac(1,i).position(1), ac(1,i).position(2)],'euclidean');
            
                % filter out aircraft that i cannot see by assigning 0
                if d(1,i) > obj.sight
                   d(1,i) = 0;  
                end
                
                % get smallest distance 
                [d_nearest, ~] = min(d(d > 0));
                if d_nearest <= obj.sep_goal
                    obj = obj.turn(90);
                end
                
            end      
        end   
        
        function obj = proactive_move(obj)
           % Input is array of AC type
           obj = obj.proactive(); 
        end
       
        function obj = proactive(obj)
            % obj = entire array with all ac
            conflicts = [0, 0];
            num_ac = size(obj,2);
            % Get all conflicts within distance sep_goal + 20
            for i=1:size(obj,2) 
                for j = 1:size(obj,2)
                   if j~=i && distance(obj(i), obj(j)) < ...
                           obj(i).sep_goal + 20 && ...
                           distance(obj(i), obj(j)) <= obj(i).sight
                       if ismember([j,i], conflicts, 'rows') == 0
                            conflicts(end+1,1:2) = [i,j];
                       end 
                   end  
                end
            end
            % Make adjustments for aircraft in conflict
            if size(conflicts, 1) > 1
                for c=2:size(conflicts,1)
                    %iterate over conflicts
                    agent1 = obj(conflicts(c,1));
                    agent2 = obj(conflicts(c,2));
                    %Almost collision
                    if distance(agent1, agent2) <= 10
                        obj(conflicts(c,1)) = ...
                            obj(conflicts(c,1)).densityturn(obj);
                        obj(conflicts(c,2)) = ...
                            obj(conflicts(c,2)).densityturn(obj);
                    elseif sameheading(agent1, agent2)
                        % Check if in front or back
                        if front(agent1, agent2)
                            %slow down one behind, speed up one in front
                            obj(conflicts(c,2)) = ...
                                obj(conflicts(c,2)).speeddown(0.9); 
                            obj(conflicts(c,1)) = ...
                                obj(conflicts(c,1)).speedup(1.1);
                        elseif front(agent2, agent1)
                            obj(conflicts(c,1)) = ...
                                obj(conflicts(c,1)).speeddown(0.9);
                            obj(conflicts(c,2)) = ...
                                obj(conflicts(c,2)).speedup(1.1);
                        else %resume speed and 1 turns 3 degrees
                            obj(conflicts(c,1)).velocity = ...
                                resume_speed(obj(conflicts(c,1))); 
                            obj(conflicts(c,2)).velocity = ...
                                resume_speed(obj(conflicts(c,2))); 
                        end    
                    elseif oppositeheading(agent1, agent2)
                        obj(conflicts(c,1)) = obj(conflicts(c,1)).turn(90);
                        obj(conflicts(c,2)) = obj(conflicts(c,2)).turn(90);
                    else %sides
                        %find common direction
                        %move the one least closest to the border 
                        %of that direction                    
                        if agent1.velocity(1) < 0 && agent2.velocity(1) < 0
                            % both move left 
                            if agent1.position(1) > agent2.position(1)
                                obj(conflicts(c,1)) = ...
                                    obj(conflicts(c,1)).turn(45);
                            else 
                                obj(conflicts(c,2)) = ...
                                    obj(conflicts(c,2)).turn(45);
                            end 
                        elseif agent1.position(1) > 0 && ...
                                agent2.position(1) > 0 
                            % both move right
                            if agent1.position(1) > agent2.position(1)
                                obj(conflicts(c,2)) = ...
                                    obj(conflicts(c,2)).turn(45);
                            else 
                                obj(conflicts(c,1)) = ...
                                    obj(conflicts(c,1)).turn(45);
                            end 
                        elseif agent1.position(2) < 0 && ...
                                agent2.position(2) < 0
                            % both move down
                            if agent1.position(2) > agent2.position(2)
                                obj(conflicts(c,2)) = ...
                                    obj(conflicts(c,2)).turn(45);
                            else 
                                obj(conflicts(c,1)) = ...
                                    obj(conflicts(c,1)).turn(45);
                            end 
                        else 
                            % both move up 
                            if agent1.position(2) > agent2.position(2)
                                obj(conflicts(c,1)) = ...
                                    obj(conflicts(c,1)).turn(45);
                            else 
                                obj(conflicts(c,2)) = ...
                                    obj(conflicts(c,2)).turn(45);
                            end 
                        end 
                    end
                end
            end 
            %For aircraft not in a conflict, set speed back to max speed 
            %max_speed/current_norm * current_velocity
            ac_in_conflict = unique(reshape(conflicts, 1, []));
            ac_not_in_conflict = setdiff(linspace(1,num_ac,num_ac), ...
                ac_in_conflict);
            for a=ac_not_in_conflict
               vel = obj(a).velocity;
               obj(a).velocity = vel * (obj(a).max_velocity/norm(vel));
            end  
        end
        
        function [v] = resume_speed(a)
            vel = a.velocity;
            v = vel * (a.max_velocity/norm(vel));
        end 
        
        function [distance] = distance(a,b)
            % Gives the distance between two agents
            distance = pdist([a.position(1), a.position(2);
                b.position(1), b.position(2)]);
        end   
        
        function ac = densityturn(ac, obj)
            %obj = all aircraft
            %ac is object of aircraft to turn
            min_distance = 10000;
            for i = 1:length(obj)
                if distance(ac,obj(i)) <= ac.sight && ...
                        distance(ac,obj(i)) > 0 ...
                    && distance(ac,obj(i)) < min_distance
                    min_distance = distance(ac,obj(i));
                    min_distance_ac = obj(i);
                end              
            end
            new_direction = [-(min_distance_ac.position(1) - ...
                ac.position(1)),- (min_distance_ac.position(2)...
                - ac.position(2))];
            new_vector = norm(ac.velocity)/(norm(new_direction))...
                * new_direction;
            ac.velocity = new_vector; 
        end
        
        function obj = speeddown(obj, factor)
            min_vel = obj.min_velocity;
            % Decreases the speed of the agent with 10%
            obj.velocity = obj.velocity * factor;
            if norm(obj.velocity) < min_vel
                obj.velocity = min_vel/norm(obj.velocity) ...
                    *obj.velocity; 
            end 
        end
        
        function obj = speedup(obj, factor)
            % Increases the speed of the agent with 5%
            obj.velocity = obj.velocity * factor;
            if obj.velocity > norm(obj.max_velocity)
               obj.velocity = obj.max_velocity/norm(obj.velocity)...
                   *obj.velocity; 
            end
        end
        
        function obj = turn(obj, degrees)
            % Rotation according to these rules: 
            % x2=cos?x1?sin?y1 
            % y2=sin?x1+cos?y1
            new_x = cosd(degrees)*obj.velocity(1) - ...
                sind(degrees)*obj.velocity(2);
            new_y = sind(degrees)*obj.velocity(1) + ...
                cosd(degrees)*obj.velocity(2);
            obj.velocity(1) = new_x;
            obj.velocity(2) = new_y;
        end
        
        function bool = sameheading(a, b)
            % Returns 1 if the heading of b, is within a 1/4pi
            % range from the heading of a
            angle1 = atan2(a.velocity(2), a.velocity(1));
            angle2 = atan2(b.velocity(2), b.velocity(1));
            bool = 0;
            if abs(angle1 - angle2) <= 1/4*pi
                bool = 1; 
            end 
        end
        
        function bool = oppositeheading(a, b)
            % Returns 1 if the heading of b, is within 3/4pi to 1pi range
            % from the heading of a
            angle1 = atan2(a.velocity(2), a.velocity(1));
            angle2 = atan2(b.velocity(2), b.velocity(1));
            difference = abs(angle1 - angle2); 
            bool = 0; 
            if difference > 3/4*pi && ...
                    difference <= pi+0.1
                bool = 1; 
            end
        end 
        
        function bool = sideheading(a, b)
           angle1 = atan2(a.velocity(2), a.velocity(1));
           angle2 = atan2(b.velocity(2), b.velocity(1));
           difference = abs(angle1 - angle2); 
           bool = 0; 
           if difference > 1/4*pi && ...
                   difference <= 3/4*pi
               bool = 1; 
           end 
        end
            
        function bool = front(a, b)
            % Agent a is in front of agent b 
            bool = 0;
            difference_y = b.position(2) - a.position(2);
            difference_x = b.position(1) - a.position(1);
            if  difference_y <= (a.velocity(1)/(-a.velocity(2)))...
                    *difference_x
                bool = 1;            
            end 
        end 
        
        function conflicts = count_conflicts(ac, d)
            conflicts = 0;
            for i=1:length(ac)
               for j=1:length(ac)
                    if i~=j && distance(ac(i),ac(j)) <= d
                        conflicts = conflicts + 1;
                    end
               end
            end
            conflicts = conflicts/2;
        end
     end  
end 
