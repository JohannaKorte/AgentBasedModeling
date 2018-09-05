% This part of the code was largely inspired by the provided example code 
% Plane.m!

classdef Plane

    properties
        ac_figure_handles
        plane_handle
        lattice_size
    end
    
    methods
        function obj = Plane(plane_handle, lattice_size, aircraft)
            obj.plane_handle = plane_handle;
            %             set(p,'xlim',[0 lattice_size(1)]);
            %             set(p,'ylim',[0 lattice_size(2)]);
            obj.lattice_size = lattice_size;
            plot(0,0);
            xlim([0 lattice_size(1)]);
            ylim([0 lattice_size(2)]);
            for i=1:length(aircraft)
                %x = [aircraft(i).position(1)-2.5 aircraft(i).position(1)+2.5 aircraft(i).position(1)-2.5 aircraft(i).position(1)-2.5];
                %y = [aircraft(i).position(2)-1.5 aircraft(i).position(2) aircraft(i).position(2)+1.5 aircraft(i).position(2)+1.5];
                %pos = [aircraft(i).position(1)-1 aircraft(i).position(2)-1 5 5];
                x = aircraft(i).position(1);
                y = aircraft(i).position(2); 
                obj.ac_figure_handles(i) =  patch(x,y,'k');
%                 obj.boids_figure_handles(i) = rectangle('Position', pos, 'Curvature', [1 1],...
%                     'FaceColor',[0 0 0]);
            end
        end
        
    end
    
end