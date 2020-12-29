function [pars,accs,ll, p_intentions, optimal_cs, p_recalls, accs_noGo, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo, bic]= ...
    fitMetaControlModelNoGoSimultaneously(modelName, accuracies,accuracies_noGo,cognitive_load,trials,trials_noGo,m,random_inhibition,p_cue_probe,p_cue_probe_noGo, p_slip,control_different)

options = optimoptions('fmincon','Display','none');
N = trials*p_cue_probe;
N_noGo = trials_noGo*p_cue_probe_noGo;
p_random_error = p_slip; %based on the BY error
gamma = 1/3;

% min lambda value
if ~exist('lambda_min','var')
    lambda_min = 0;
end

% Model Type
if modelName == "InhibitionRecall"
    modelTypeBaseline = @metaControlModelInhibitionRecall;
    modelType = @metaControlModelInhibitionRecallNoGo;
    
    if control_different == 0
        % same control cost - all pars equal
        objective = ...
        @(pars) -(logLikelihoodOfRelFreq( accuracies, N, ...
        outselect(1,@metaControlModelInhibitionRecall,pars(1),pars(2), gamma,cognitive_load,...
        pars(3),pars(4),pars(5),m,random_inhibition,p_cue_probe,p_slip)) ...
        + logLikelihoodOfRelFreq( accuracies_noGo, N_noGo, ...
        outselect(1,@metaControlModelInhibitionRecallNoGo,pars(1),pars(2), gamma,cognitive_load,...
        pars(3),pars(4),pars(5),m,random_inhibition,p_cue_probe_noGo,p_slip)));

         % Optimization Model with 5 params 
        [pars,neg_ll]=fmincon(objective, [2,2,0.05,2,0.1], [], ...
        [],[],[],[0;0;0;0;lambda_min],[10;10;1;10;1/3],[], options );
    
        ll = -neg_ll;
        bic = numel(pars)*log(trials+trials_noGo)-2*ll;

        [accs, p_intentions, optimal_cs, p_recalls] = modelTypeBaseline(pars(1),pars(2),gamma,cognitive_load,pars(3),pars(4),pars(5),m,random_inhibition,p_cue_probe,p_slip);
        [accs_noGo, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo] = modelType(pars(1),pars(2),gamma,cognitive_load,pars(3),pars(4),pars(5),m,random_inhibition,p_cue_probe_noGo,p_slip);

     elseif control_different == 1
        % different control cost
        objective = ...
        @(pars) -(logLikelihoodOfRelFreq( accuracies, N, ...
        outselect(1,@metaControlModelInhibitionRecall,pars(1),pars(2),...
        gamma,cognitive_load,pars(3), pars(4),pars(5),m,random_inhibition,p_cue_probe,p_slip)) ...
        + logLikelihoodOfRelFreq( accuracies_noGo, N_noGo, ...
        outselect(1,@metaControlModelInhibitionRecallNoGo,pars(1),pars(2),...
        gamma,cognitive_load,pars(6), pars(4),pars(5),m,random_inhibition,p_cue_probe_noGo,p_slip)));

       
        [pars,neg_ll]=fmincon(objective, [2,2,0.05,2,0.1,0.05], [], ...
        [],[],[],[0;0;0;0;lambda_min;0],[10;10;1;10;1/3;1],[], options);
        
  
        ll = -neg_ll;
        bic = numel(pars)*log(trials+trials_noGo)-2*ll;


        [accs, p_intentions, optimal_cs, p_recalls] = ...
        metaControlModelInhibitionRecall(pars(1),pars(5),...
        gamma,cognitive_load,pars(2),pars(3),...
        pars(4),m,random_inhibition,p_cue_probe,p_slip);
        [accs_noGo, ~, ~, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo] = ...
        metaControlModelInhibitionRecallNoGo(pars(1),pars(5),...
        gamma,cognitive_load,pars(6),pars(3), ...
        pars(4),m,random_inhibition,p_cue_probe_noGo,p_slip);

    elseif control_different == 3
        
        % TO DO: correct number of parameters in minimization fuction
        
        % all different parameters
        objective = ...
        @(pars) -(logLikelihoodOfRelFreq( accuracies, N, ...
        outselect(1,@metaControlModelInhibitionRecall,pars(1),pars(5),...
        gamma,cognitive_load,pars(2),...
        pars(3),pars(4),m,random_inhibition,p_cue_probe,p_slip)) ...
        + logLikelihoodOfRelFreq( accuracies_noGo, N_noGo, ...
        outselect(1,@metaControlModelInhibitionRecallNoGo,pars(6),pars(10),...
        gamma,cognitive_load,pars(7), ...
        pars(8),pars(9),m,random_inhibition,p_cue_probe_noGo,p_slip)));

        [pars,neg_ll]=fmincon(objective, [2,2,0.05,2,0.1, 2,2,0.05,2,0.1], [], ...
        [],[],[],[0;0;0;0;lambda_min; 0;0;0;0;lambda_min],[10;10;1;10;1/3; 10;10;1;10;1/3],[], options );
    
        ll = -neg_ll;
        bic = numel(pars)*log(trials+trials_noGo)-2*ll;


        [accs, p_intentions, optimal_cs, p_recalls] = ...
        modelTypeBaseline(pars(1),pars(5),...
        gamma,cognitive_load,pars(2),pars(3),...
        pars(4),m,random_inhibition,p_cue_probe,p_slip);
        [accs_noGo, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo] = ...
        modelType(pars(6),pars(10),...
        gamma,cognitive_load,pars(7),pars(8), ...
        pars(9),m,random_inhibition,p_cue_probe_noGo,p_slip);



    end
    
elseif  modelName == "RecallOverride"
    modelTypeBaseline = @metaControlModelRecallOverride;
    modelType = @metaControlModelRecallOverrideNoGo;
    
        if control_different == 0
        % same control cost - all pars equal
        objective = ...
        @(pars) -(logLikelihoodOfRelFreq( accuracies, N, ...
        outselect(1,@metaControlModelRecallOverride,pars(1),pars(2), gamma,cognitive_load,...
        pars(3),pars(4),m,random_inhibition,p_cue_probe,p_slip)) ...
        + logLikelihoodOfRelFreq( accuracies_noGo, N_noGo, ...
        outselect(1,@metaControlModelRecallOverrideNoGo,pars(1),pars(2), gamma,cognitive_load,...
        pars(3),pars(4),m,random_inhibition,p_cue_probe_noGo,p_slip)));

         % Optimization Model with 5 params 
        [pars,neg_ll]=fmincon(objective, [2,2,2,0.1], [], ...
        [],[],[],[0;0;0;lambda_min],[10;10;10;1/3],[], options );
    
        ll = -neg_ll;
        bic = numel(pars)*log(trials+trials_noGo)-2*ll;

        [accs, p_intentions, optimal_cs, p_recalls] = modelTypeBaseline(pars(1),pars(2),gamma,cognitive_load,pars(3),pars(4),m,random_inhibition,p_cue_probe,p_slip);
        [accs_noGo, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo] = modelType(pars(1),pars(2),gamma,cognitive_load,pars(3),pars(4),m,random_inhibition,p_cue_probe_noGo,p_slip);

     elseif control_different == 1
         % Doesn`t make sense anymore because there is no inhibition in
         % this model
%         % different control cost
%         objective = ...
%         @(pars) -(logLikelihoodOfRelFreq( accuracies, N, ...
%         outselect(1,@metaControlModelInhibitionRecall,pars(1),pars(2),...
%         gamma,cognitive_load,pars(3), pars(4),pars(5),m,random_inhibition,p_cue_probe,p_slip)) ...
%         + logLikelihoodOfRelFreq( accuracies_noGo, N_noGo, ...
%         outselect(1,@metaControlModelInhibitionRecallNoGo,pars(1),pars(2),...
%         gamma,cognitive_load,pars(6), pars(4),pars(5),m,random_inhibition,p_cue_probe_noGo,p_slip)));
% 
%        
%         [pars,neg_ll]=fmincon(objective, [2,2,0.05,2,0.1,0.05], [], ...
%         [],[],[],[0;0;0;0;lambda_min;0],[10;10;1;10;1/3;1],[], options);
%         
%   
%         ll = -neg_ll;
%         bic = numel(pars)*log(trials+trials_noGo)-2*ll;
% 
% 
%         [accs, ~, ~, p_intentions, optimal_cs, p_recalls] = ...
%         metaControlModelInhibitionRecall(pars(1),pars(5),...
%         gamma,cognitive_load,pars(2),pars(3),...
%         pars(4),m,random_inhibition,p_cue_probe,p_slip);
%         [accs_noGo, ~, ~, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo] = ...
%         metaControlModelInhibitionRecallNoGo(pars(1),pars(5),...
%         gamma,cognitive_load,pars(6),pars(3), ...
%         pars(4),m,random_inhibition,p_cue_probe_noGo,p_slip);

    elseif control_different == 3
        % all different parameters
        objective = ...
        @(pars) -(logLikelihoodOfRelFreq( accuracies, N, ...
        outselect(1,@metaControlModelRecallOverride,pars(1),pars(2),...
        gamma,cognitive_load,pars(3),pars(4),m,random_inhibition,p_cue_probe,p_slip)) ...
        + logLikelihoodOfRelFreq( accuracies_noGo, N_noGo, ...
        outselect(1,@metaControlModelRecallOverrideNoGo,pars(5),pars(6),...
        gamma,cognitive_load,pars(7),pars(8),m,random_inhibition,p_cue_probe_noGo,p_slip)));

        [pars,neg_ll]=fmincon(objective, [2,2,2,0.1, 2,2,2,0.1], [], ...
        [],[],[],[0;0;0;lambda_min; 0;0;0;lambda_min],[10;10;10;1/3; 10;10;10;1/3],[], options );
    
        ll = -neg_ll;
        bic = numel(pars)*log(trials+trials_noGo)-2*ll;


        [accs, p_intentions, optimal_cs, p_recalls] = ...
        modelTypeBaseline(pars(1),pars(2),...
        gamma,cognitive_load,pars(3),pars(4),m,random_inhibition,p_cue_probe,p_slip);
        [accs_noGo, p_intentions_noGo, optimal_cs_noGo, p_recalls_noGo] = ...
        modelType(pars(5),pars(6),...
        gamma,cognitive_load,pars(7),pars(8),m,random_inhibition,p_cue_probe_noGo,p_slip);



    end
    

end
% same cost
%logLikelihoodAllData(alpha,deltaT,�,controlCost1,controlCost2)=logLikelihoodNoGo(alpha,deltaT,�,controlCost1)+logLikelihoodStandard(alpha,deltaT,�,controlCost1)

% different control cost
%logLikelihoodAllData(alpha,deltaT,�,controlCost1,controlCost2)=logLikelihoodNoGo(alpha,deltaT,�,controlCost1)+logLikelihoodStandard(alpha,deltaT,�,controlCost2)