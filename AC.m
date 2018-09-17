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
            obj.angle = (2*pi).*rand;
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
     end  
end 
