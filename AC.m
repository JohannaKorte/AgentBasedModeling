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
    %   r -          - How far an agent can fly past the lattice until 
    %                  it will come back on the other side 
    %
    % AC Methods:
    %   AC           - Initialize new AC instance
    %   move         - Calculates new property values by calling functions
    %   update       - Move the agent one step forward
    %   borders      - Makes sure the borders of the lattice wrap around
    
    properties 
       angle 
       position
       velocity
       max_velocity
       r
    end
    
    methods 
        function obj = AC(xpos, ypos, maxv) 
            % Initializes a new aircraft agent with an initial angle
            % position, speed and the maximum speed.
            obj.angle = (2*pi).*rand;
            obj.position = [xpos ypos];
            obj.velocity = [cos(obj.angle) sin(obj.angle)];
            obj.max_velocity = maxv;
            obj.r = 0;  %Space around the square that needs to be traversed
            %before coming out again on the other side.
        end
   
        function obj = move(obj,aircraft)
            % Currenlty placeholder, later used to perform function calls
            % to functions that ensure the aircraft do not collide.
            % This will most likely be done by altering the velocity in 
            % such a way that the speed is not affected.
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
    end 
    
    
end 
