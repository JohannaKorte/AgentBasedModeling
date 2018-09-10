% Defines and creates (functions for) the aircraft agents AC
classdef AC
    
    properties 
       angle 
       position
       velocity
       max_velocity
       r
    end
    
    methods 
        % Makes an object/aicraft
        function obj = AC(xpos, ypos, maxv) 
            obj.angle = (2*pi).*rand;
            obj.position = [xpos ypos];
            obj.velocity = [cos(obj.angle) sin(obj.angle)];
            obj.max_velocity = maxv;
            obj.r = 0;
        end
    
        %% What isthe use of this?
        
        function obj = flock(obj,aircraft)
            %Calculates action
            obj = obj; 
            %obj=obj.apply_force(sep,coh,ali);
        end
        %% 
        % Update the object/aircraft each step
        function obj = update(obj)
            obj = obj;
        end
        
        % Define the form of the object? Or the borders of the grid?
        function obj = borders(obj, lattice_size)
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
        
    end 
    
    
end 

%% Comments
% Do we need the apply force function?
% Do we need the seperation function?