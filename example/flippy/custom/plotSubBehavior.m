function [flow] = plotSubBehavior(nlp,sol)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Export the optimization result
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [tspan, states, inputs, params] = exportSolution(nlp, sol);

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% collect time and states
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        flow.t = tspan;
        flow.states = states;
        flow.inputs = inputs;
        flow.params = params;
        flow.nlp = nlp;
        flow.sol = sol;
        
%         %% collision check variables
%         vars = nlp.OptVarTable;
%         windices = horzcat(vars.w.Indices);
%         w = sol(windices);
%         
%         dim = min(size(w));
%         
%         plot(405);
%         if dim == 1
%             subplot(2,1,1);
%             bar(w');
%             subplot(2,1,2);
%             bar((100-w)');
%         else
%             for i=1:dim
%                 subplot(dim,1,i);
%                 bar(w(i,:)');
%             end
%         end
%         flow.w = w;

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% plot the basic result
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Analyze(flow);


     
        
end