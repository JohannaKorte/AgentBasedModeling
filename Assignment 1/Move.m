classdef Move
    % Move   Summary of Move
    % This class implements the execution of precalculated movements for 
    % all agents
    %
    % Move properties:
    %   ac              - array of aircraft in simulation
    %   lattice_size    - dimensions of the simulation lattice
    %   step_counter=1  - keeps track of ticks
    %
    % Move methods:
    %   Move            - initializes class 
    %   run             - runs simulation by calculating move and updating
    %   move            - calculates move
    %   update_ac       - moves agent one step in velocity direction
    %   border          - makes sure the grid 'wraps around'
    %   render          - updates the simulation figure
    
    
    properties
        ac               
        lattice_size    
        step_counter=1;
    end
    
    methods
        % Sets the properties aircraft and lattice_size 
        function obj = Move(aircraft,lattice_size) 
            obj.ac=aircraft;
            obj.lattice_size=lattice_size;
        end
        
        function array = run(obj, plane, mode, ticks,visualize, trace)
            t = 1;
            %initialize distances & conflicts 
            conflicts = zeros(1,ticks);
            conflicts(1,t) = obj.ac.count_conflicts(20);
            collisions = zeros(1,ticks);
            collisions(1,t) = obj.ac.count_conflicts(3.4);
            array = struct;
            while t <= ticks 
                obj = move(obj, mode);
                obj = update_ac(obj);
                obj = borders(obj);
                % Only if asked to visualize
                if visualize
                    [obj,plane] = render(obj,plane,trace);
                end 
                conflicts(1,t) = obj.ac.count_conflicts(...
                    obj.ac(1).sep_goal);
                collisions(1,t) = obj.ac.count_conflicts(3.4);
                t = t +1;
            end
            distances = [];
            for a=1:length(obj.ac)
                for b=1:length(obj.ac)
                    distances(a,b) = distance(obj.ac(a),...
                            obj.ac(b));
                end 
            end
            array.conflicts = conflicts;
            array.collisions = collisions;
            array.distances = distances;
        end
        
        
        % Moves the whole obj (per aircraft), depends on agent type
        % (function 'move()' can be found in AC.m)
        function obj = move(obj, mode)
            if strcmp(mode, 'reactive')
                for i=1:length(obj.ac)
                    obj.ac(i)=obj.ac(i).move(obj.ac);
                end
            else 
                obj.ac = obj.ac.proactive_move(); 
            end
        end
        
        % Updates the whole obj per aircraft
        % (function 'update()' can be found in AC.m)
        function obj = update_ac(obj)
            for i=1:length(obj.ac)
                obj.ac(i)=obj.ac(i).update();
            end
        end
        
        % the whole obj per aircraft 
        % (function 'borders()' can be found in AC.m)
        function obj = borders(obj)
            for i=1:length(obj.ac)
                obj.ac(i) = obj.ac(i).borders(obj.lattice_size);
            end
        end

        % creates the updates visualisation
        function [obj, plane] = render(obj,plane, trace)
            fprintf('Rendering %s \n', num2str(obj.step_counter))
            for i=1:length(obj.ac)        
                % delete previous figures (so you can show updated ones)
                delete(plane.ac_figure_handles(i));
                delete(plane.conflict_handles(i));
                % black circle representing the agent
                h = rectangle('Position', [obj.ac(i).position(1)-1.7...
                    obj.ac(i).position(2)-1.7 3.4 3.4], ...
                    'Curvature', [1 1], 'FaceColor', 'k');
                plane.ac_figure_handles(i) = h;    
                % Light blue circle representing conflict zone per agent
                plane.conflict_handles(i) = viscircles( ...
                    [obj.ac(i).position(1) obj.ac(i).position(2)], ...
                    obj.ac(i).sep_goal, 'Color', [0 166/255 214/255], ...
                    'LineWidth', 0.5);
                % Display trace lines if wanted 
                if trace
                    if abs(obj.ac(i).previous_pos(1) - ...
                            obj.ac(i).position(1)) <= ...
                            obj.lattice_size(1) -10 ...
                            && abs(obj.ac(i).previous_pos(2)- ...
                            obj.ac(i).position(2)) <= ...
                            obj.lattice_size(2)-10
                        plane.line_handles(i) = line(...
                        [obj.ac(i).previous_pos(1) ...
                        obj.ac(i).position(1)], ...
                        [obj.ac(i).previous_pos(2) ...
                        obj.ac(i).position(2)], 'color', 'red');
                    end 
                end 
            end
            drawnow;
            obj.step_counter=obj.step_counter+1;
        end
    end
    
end

