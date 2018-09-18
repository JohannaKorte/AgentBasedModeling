classdef AC
    % AC   Summary of AC
    % This class is meant for initializing aircraft agents and functions
    % that can be applied to these agents
    %
    % AC properties:
    %   angle        - The agents angle in radials
    %   position     - The agents [x, y] position
    %   velocity     - The agent's speed as [x speed, yspeed]
    %   max_velocity - The agent's maximum speed
    %   r            - How far an agent can fly past the lattice until 
    %                  it will come back on the other side 
    %   sight        - How far the agent is able to see around himself
    %
    % AC Methods:
    %   AC           - Initialize new AC instance
    %   move         - Calculates new property values by calling functions
    %   update       - Move the agent one step forward
    %   borders      - Makes sure the borders of the lattice wrap around
    %   reactive     - Implements a reactive strategy
    
    properties 
       angle 
       position
       velocity
       max_velocity
       r
       sight
    end
    
    methods 
        function obj = AC(xpos, ypos, maxv, sight) 
            % Initializes a new aircraft agent with an initial angle
            % position, speed and the maximum speed.
            %obj.angle = (2*pi).*rand;
            obj.angle = 0.5*pi;
            obj.position = [xpos ypos];
            obj.velocity = [cos(obj.angle) sin(obj.angle)];
            obj.max_velocity = maxv;
            obj.r = 0;  %Space around the square that needs to be traversed
            %before coming out again on the other side.
            obj.sight = sight; 
        end
   
        function obj = move(obj,aircraft)
            % Call functions that will ensure separation
            obj.velocity = obj.reactive(aircraft); %this changes obj's properties
        end
        
        function obj = proactive_move(obj, ac)
           % Input is array of AC type
           obj = obj.proactive(obj); 
           %obj.velocity = ;
        end
        
        function obj = update(obj)
            % Make the agent move one step into its desired direction by
            % updating its position using the velocity attribute
            obj.position = obj.position + obj.velocity;
        end
        
        function obj = borders(obj, lattice_size)
            % Makes sure that the aircraft cannot fall of the grid, by 
            % connecting opposite sides to eachother.
            if obj.position(1) < -obj.r %x coordinate < obj.r?
                obj.position(1)=lattice_size(1)+obj.r; %move to other x end
            end
            
            if obj.position(2) < -obj.r %y coordinate < obj.r?
                obj.position(2)=lattice_size(2)+obj.r; %move to other y end
            end
            
            if obj.position(1) > lattice_size(1) + obj.r %x > latticesize
                obj.position(1)=-obj.r;     % move to beginning x of board
            end
            
            if obj.position(2) > lattice_size(2) + obj.r %y > latticesize
                obj.position(2)=-obj.r;     % move to beginning y of board
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
                [d_nearest, nearest_index] = min(d(d > 0));
                
                % If nearest plane closer than min separation, act
                 if d_nearest < 20
                     %get closest aircraft index position and determine in 
                     %which quadrant they are of me;
                     threat_position = ac(nearest_index).position; 
                     % x smaller, y smaller
                     if obj.position(1) < threat_position(1) && ...
                             obj.position(2) < threat_position(2)
                         v = [threat_position(1)-obj.position(1), ...
                             threat_position(2)-obj.position(2)];
                     % x smaller, y larger
                     elseif obj.position(1) < threat_position(1) && ...
                             obj.position(2) > threat_position(2)
                         v = [threat_position(1)-obj.position(1), ...
                             obj.position(2) - threat_position(2)];
                     % x larger, y smaller
                     elseif obj.position(1) > threat_position(1) && ...
                             obj.position(2) < threat_position(2)
                         v= [obj.position(1) - threat_position(1), ...
                             threat_position(2)-obj.position(2)];
                     % x larger, y larger
                     elseif obj.position(1) > threat_position(1) && ...
                             obj.position(2) > threat_position(2)
                         v= [obj.position(1) - threat_position(1), ...
                             obj.position(2) - threat_position(2)];
                     end 
                     velocity = [-v(2) v(1)]; %turn 90 degrees away from their separation
                     velocity = velocity/norm(velocity); %normalize velocity
                 end                
            end    
        end   
        
        function obj = proactive(obj, ac)
            % obj = entire array with all ac
            conflicts = [0, 0];
            num_ac = size(obj,2);
            % Get all conflicts within 20 distance
            for i=1:size(obj,2) 
                for j = 1:size(obj,2)
                   if j~=i && distance(obj(i), obj(j)) < 20 && ...
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
                    
                    % if almost same heading, the one behind slows down and
                    % the one in front speeds up 
                    if sameheading(agent1, agent2)
                        % Check if in front or back
                        if front(agent1, agent2)
                            %slow down one behind, speed up one in front
                            obj(conflicts(c,2)) = obj(conflicts(c,2)).speeddown(); 
                            obj(conflicts(c,1)) = obj(conflicts(c,1)).speedup();
                        elseif front(agent2, agent1)
                            obj(conflicts(c,1)) = obj(conflicts(c,1)).speeddown();
                            obj(conflicts(c,2)) = obj(conflicts(c,2)).speedup();
                        else %resume speed for 
                            obj(conflicts(c,1)).velocity = ...
                                resume_speed(obj(conflicts(c,1))); 
                            obj(conflicts(c,2)).velocity = ...
                                resume_speed(obj(conflicts(c,2))); 
                        end
                    elseif oppositeheading(agent1, agent2)    
                        % TODO: Check if on collision course
                            % TODO: both move right 
                        % TODO: Expand
                    elseif sideheading(agent1, agent2)
                        %TODO: Expand
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
        
        function v = resume_speed(a)
            vel = a.velocity;
            v = vel * (a.max_velocity/norm(vel));
        end 
        
        function [distance] = distance(a,b)
            % Gives the distance between two agents
            distance = pdist([a.position(1), a.position(2);
                b.position(1), b.position(2)]);
        end   
        
        function obj = speeddown(obj)
            % Decreases the speed of the agent with 10%
            obj.velocity = obj.velocity * 0.9;
        end
        
        function obj = speedup(obj)
            % Increases the speed of the agent with 5%
            obj.velocity = obj.velocity * 1.05;
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
                    difference <= pi
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
            f1 = [a.velocity(1), a.velocity(2)];
            f2 = [-a.velocity(1), a.velocity(2)];
            
            %        hellingsgetal
            %y_b >= f1(2)/f1(1) * x     % x is xposition van agent b tov a
            difference = b.position(2) - a.position(2);
            if b.position(2) >= (f1(2)/f1(1))*difference ...
                    || b.position(2) >= (f2(2)/f2(1))*difference
                bool = 1; 
            end               
        end 
        
     end  
end 
