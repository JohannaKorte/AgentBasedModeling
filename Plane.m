% This part of the code was largely inspired by the provided example code 
% Plane.m of the flock_example!

classdef Plane
    % Plane     Summary of Plane
    % This class is meant for initializing the simulation plane with the
    % aircraft and their conflict zones on it
    %
    % Plane properties:
    %   ac_figure_handles        - aircraft agent visualization
    %   conflict_handles         - conflict zone visualization
    %   plane_handle             - figure to draw on
    %   lattice_size             - size of the simulation lattice
    %
    % Plane methods:
    %   Plane                    - initialize simulation 

    properties
        ac_figure_handles
        conflict_handles
        plane_handle
        lattice_size
    end
    
    methods
        % Create the plane with all aircraft in it
        function obj = Plane(plane_handle, lattice_size, aircraft)
            obj.plane_handle = plane_handle;
            obj.lattice_size = lattice_size;
            plot(0,0);
            xlim([0 lattice_size(1)]);
            ylim([0 lattice_size(2)]);
            
            for i=1:length(aircraft)
                % Draw plane dots
                obj.ac_figure_handles(i) = ...
                    rectangle('Position',[aircraft(i).position(1) ...
                    aircraft(i).position(2) 3.4 3.4], ...
                    'Curvature',[1 1], 'FaceColor','k');
                % Draw conflict zone circles
                obj.conflict_handles(i) = viscircles(...
                    [aircraft(i).position(1) aircraft(i).position(2)], ...
                    20, 'Color', [0 166/255 214/255], 'LineWidth', 0.5);
            end
        end
    end 
end
