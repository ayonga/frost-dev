classdef (ConstructOnLoad) TimeStepData < event.EventData
    % The data type to store the time step data for the animator
    % 
    % @author omar @date 2017-06-01
    % 
    % Copyright (c) 2017, UMICH Biped Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/BSD-3-Clause

   properties
      x
      t
   end
   
   methods
      function obj = TimeStepData(t, x)
         obj.x = x;
         obj.t = t;
      end
   end
end
