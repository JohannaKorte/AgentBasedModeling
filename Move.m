%This class was inspired by the Flock class that was provided in the Flock
%example!

classdef Move
    properties
        ac              % array of aircraft in sim
        lattice_size    % raster_grootte
        step_counter=1;
    end
    
    methods
        % Sets the properties aircraft and lattice_size 
        function obj = Move(aircraft,lattice_size) 
            obj.ac=aircraft;
            obj.lattice_size=lattice_size;
        end
        
        % Makes the simulation run, 
        % by first calculating the movement of the object, 
        % then updating the position of the object, then rendering all.
        % Function uses the 4 functions below
        function run(obj, plane)
            while true                          % Loop until one of them is false?
                obj = move(obj);
                obj = update_ac(obj);
                obj = borders(obj);
                [obj,plane] = render(obj,plane);
            end
        end
        
        % Updates the whole obj per aircraft
        % (function 'update()' can be found in AC.m)
        function obj = update_ac(obj)
            for i=1:length(obj.ac)
                obj.ac(i)=obj.ac(i).update();
            end
        end
        
        % Moves the whole obj (per aircraft)
        % (function 'move()' can be found in AC.m)
        function obj = move(obj)
            for i=1:length(obj.ac)
                obj.ac(i)=obj.ac(i).move(obj.ac);
            end
        end
        
        % Renders the whole obj per aircraft 
        % (function 'render()' can be found in AC.m)
        function [obj,plane] = render(obj,plane)
            obj.step_counter=obj.step_counter+1;
            fprintf('Rendering %s \n',num2str(obj.step_counter))
            
            % Theta = angle between plane and aircraft (calc by tan^-1)
                    % use norm = magnitude (sum of cross and dot product
                    % squared and squared root)
                    % cross and dot product from [velo 0] and [1 0 0] ????
            for i=1:length(obj.ac)
                delete(plane.ac_figure_handles(i)); % delete previous figures (so you can show updated ones) 
                theta = atan2(norm(cross([obj.ac(i).velocity 0],[1 0 0])),dot([obj.ac(i).velocity 0],[1 0 0]));
              %  x and y give outlines of triangle (= aircraft)
                x = [obj.ac(i).position(1)-2.5 obj.ac(i).position(1)+2.5 obj.ac(i).position(1)-2.5 obj.ac(i).position(1)-2.5];
                y = [obj.ac(i).position(2)-1.5 obj.ac(i).position(2) obj.ac(i).position(2)+1.5 obj.ac(i).position(2)+1.5];
              % function 'patch()' creates a polygone (so it connects the
              % x and y).
                plane.ac_figure_handles(i) =  patch(x,y,'k');
              % rotate the triangle (=aircraft)
                rotate(plane.ac_figure_handles(i), [0 0 1], rad2deg(theta), [obj.ac(i).position(1) obj.ac(i).position(2) 0]);
            end
            drawnow;
        end
        
        % the whole obj per aircraft 
        % (function 'borders()' can be found in AC.m)
        function obj = borders(obj)
            for i=1:length(obj.ac)
                obj.ac(i) = obj.ac(i).borders(obj.lattice_size);
            end
        end
        
    end
    
end

