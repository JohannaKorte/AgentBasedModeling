% This part of the code was largely inspired by the provided example code 
% Plane.m!

classdef Plane

    properties
        ac_figure_handles
        plane_handle
        lattice_size
    end
    
    methods
        % This function creates the plane with all aircraft in it????
        function obj = Plane(plane_handle, lattice_size, aircraft)
            obj.plane_handle = plane_handle;
            obj.lattice_size = lattice_size;
            plot(0,0);
            xlim([0 lattice_size(1)]);
            ylim([0 lattice_size(2)]);
            
            for i=1:length(aircraft)
                pos = [aircraft(i).position(1)-1 aircraft(i).position(2)-1 5 5]; 
                obj.ac_figure_handles(i) = ...
                    viscircles([aircraft(i).position(1) aircraft(i).position(2)], 1.7, 'Color', 'k');
            end
        end
        
    end
    
end

% %                %%the same as in Move (see function 'render()')
% %                 x = [aircraft(i).position(1)-2.5 aircraft(i).position(1)+2.5 aircraft(i).position(1)-2.5 aircraft(i).position(1)-2.5];
% %                 y = [aircraft(i).position(2)-1.5 aircraft(i).position(2) aircraft(i).position(2)+1.5 aircraft(i).position(2)+1.5];
% %                 %x = aircraft(i).position(1);
% %                 %y = aircraft(i).position(2);
% %                 pos = [aircraft(i).position(1)-1 aircraft(i).position(2)-1 5 5]; 
% %                 obj.ac_figure_handles(i) = patch(x,y,'k');
