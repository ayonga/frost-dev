classdef (ConstructOnLoad) TimeStepData < event.EventData
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