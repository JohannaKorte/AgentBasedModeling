%This class was inspired by the Flock class that was provided in the Flock
%example!

classdef Move
    properties
        ac
        lattice_size
        step_counter=1;
    end
    
    methods
        
        function obj = Move(boids,lattice_size)
            obj.ac=boids;
            obj.lattice_size=lattice_size;
        end
        
        function run(obj, plane)
            while true
                obj = flock(obj);
                obj = update_boids(obj);
                obj = borders(obj);
                [obj,plane] = render(obj,plane);
            end
        end
        
        function obj = update_boids(obj)
            for i=1:length(obj.ac)
                obj.ac(i)=obj.ac(i).update();
            end
        end
        
        function obj = flock(obj)
            for i=1:length(obj.ac)
                obj.ac(i)=obj.ac(i).flock(obj.ac);
            end
        end
        
        
        function [obj,plane] = render(obj,plane)
            obj.step_counter=obj.step_counter+1;
            fprintf('Rendering %s \n',num2str(obj.step_counter))
           
            for i=1:length(obj.ac)
                delete(plane.ac_figure_handles(i));
                theta = atan2(norm(cross([obj.ac(i).velocity 0],[1 0 0])),dot([obj.ac(i).velocity 0],[1 0 0]));
                x = [obj.ac(i).position(1)-2.5 obj.ac(i).position(1)+2.5 obj.ac(i).position(1)-2.5 obj.ac(i).position(1)-2.5];
                y = [obj.ac(i).position(2)-1.5 obj.ac(i).position(2) obj.ac(i).position(2)+1.5 obj.ac(i).position(2)+1.5];
                plane.ac_figure_handles(i) =  patch(x,y,'k');
                rotate(plane.ac_figure_handles(i), [0 0 1], rad2deg(theta), [obj.ac(i).position(1) obj.ac(i).position(2) 0]);
            end
            drawnow;
        end
        
        function obj = borders(obj)
            for i=1:length(obj.ac)
                obj.ac(i) = obj.ac(i).borders(obj.lattice_size);
            end
        end
        
    end
    
end

