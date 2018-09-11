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
        function obj = AC(xpos, ypos, maxv)
            obj.angle = (2*pi).*rand;
            obj.position = [xpos ypos];
            obj.velocity = [cos(obj.angle) sin(obj.angle)];
            obj.max_velocity = maxv;
            obj.r = 0;
        end
    
        function obj = move(obj,aircraft)
            %Calculates action
            %vel = obj.separate(aircraft);
            obj = obj;
            %obj.velocity = obj.velocity - vel;
            %obj=obj.apply_force(sep,coh,ali);
        end
        
        function obj = update(obj)
            obj.position = obj.position + obj.velocity;
        end
        
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
        
        
        function [steer] = separate(obj, ac)
            desired_separation = 30;
            steer = [0,0];
            count = 0;
            positions = zeros(2,length(ac));       %get ac positions
            for i=1:1:length(ac)
                positions(:,i) = ac(i).position;
            end
            d = pdist([obj.position; positions']); 
            d = d(1:length(ac)); %get distances to other aircraft
            for i=1:1:length(ac)
                if d(i) > 0 && d(i) <  desired_separation 
                    if obj.velocity > 0
                        steer = obj.velocity./2; 
                    end 
%                     difference = obj.position - ac(i).position;
%                     difference = difference./norm(difference);
%                     difference = difference./d(i);
%                     steer = steer + difference;
                    count = count+1;
                end
                
%                 if count > 0
%                     steer = steer./count;
%                 end
%                 
%                 if norm(steer) > 0
%                     steer = steer./norm(steer).*obj.max_velocity;
%                     steer = steer - obj.velocity;
%                 end
            end
        end
        
    end 
    
    
end 