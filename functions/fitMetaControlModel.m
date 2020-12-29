%function [alpha_cost_interference,accs,proactivity_weights,ll]= ...
function [pars, accs, ll, p_intentions, optimal_cs, p_recalls, bic]= ...
    fitMetaControlModel(modelName, isNoGo, accuracies, load, trials, m, random_inhibition, p_cue_probe, p_slip, lambda_min)

options = optimoptions('fmincon','Display','none');
N = trials*p_cue_probe;
gamma = 1/3;

% min lambda value
if ~exist('lambda_min','var')
    lambda_min = 0;
end

    if modelName ~= "RecallOverride" & modelName ~= "NoInhibition"
%%        %%%%%% MODEL 1 - Inhibition Recall (Extended Model)  %%%%%%
        if modelName == "InhibitionRecall"   
            if isNoGo == 1
                modelType = @metaControlModelInhibitionRecallNoGo;
                
                objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
                        outselect(1,@metaControlModelInhibitionRecallNoGo,pars(1), ...% pars(2) = alpha for A and X trials! 
                                    pars(2), gamma,load,pars(3),pars(4), ...          % pars(3) = control_cost;
                                    pars(5),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                         % output of metaControlModel = predicted accuracies          % pars(5) = lambda (interference of cognitive load);

            elseif isNoGo == 0
                modelType = @metaControlModelInhibitionRecall;

                objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
                        outselect(1,@metaControlModelInhibitionRecall, pars(1), ...   % pars(2) = alpha for A and X trials! 
                                    pars(2), gamma,load,pars(3),pars(4), ...          % pars(3) = control_cost;
                                    pars(5),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                         % output of metaControlModel = predicted accuracies          % pars(5) = lambda (interference of cognitive load);
            end
        end
         
            
%%         %%%%%% MODEL 3 - Inhibition Habitual  %%%%%%
         if modelName == "InhibitionHabitual"
             if isNoGo == 1
                modelType = @metaControlModelInhibitionHabitualNoGo;
                
                objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
                        outselect(1,@metaControlModelInhibitionHabitualNoGo, pars(1), ...% pars(2) = alpha for A and X trials! 
                                    pars(2), gamma,load,pars(3),pars(4), ...          % pars(3) = control_cost;
                                    pars(5),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                         % output of metaControlModel = predicted accuracies          % pars(5) = lambda (interference of cognitive load);
  
                         
             elseif isNoGo == 0
                modelType = @metaControlModelInhibitionHabitual;
                
                objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
                        outselect(1,@metaControlModelInhibitionHabitual, pars(1), ... % pars(2) = alpha for A and X trials! 
                                    pars(2), gamma,load,pars(3),pars(4), ...          % pars(3) = control_cost;
                                    pars(5),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                         % output of metaControlModel = predicted accuracies          % pars(5) = lambda (interference of cognitive load);
  
             end
         end
                
%%       %%% Fit Models 1 or 3 (5 params) %%%
      
%         objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
%                 outselect(1,@modelType, pars(1), ...                          % pars(2) = alpha for A and X trials! 
%                             pars(2), gamma,load,pars(3),pars(4), ...          % pars(3) = control_cost;
%                             pars(5),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                 % output of metaControlModel = predicted accuracies            % pars(5) = lambda (interference of cognitive load);   
                                                                                   
        [pars,neg_ll]=fmincon(objective, [2,2,0.1,2,0.1], [], ...
        [],[],[],[0;0;0;0;lambda_min],[10;10;1;10;1/3],[], options );  % min max

        % Function output - parameters
        [accs, p_intentions, optimal_cs, p_recalls] = ...
        modelType(pars(1), pars(2), gamma, load, pars(3), pars(4), ...
        pars(5), m, random_inhibition, p_cue_probe, p_slip);
         
        npars = numel(pars);
              
%%    %%%%%% MODEL 4  Recall Override  %%%%%%
    else % if recall override or no inhibition
           if modelName == "RecallOverride"
              if isNoGo == 1
                    modelType = @metaControlModelRecallOverrideNoGo;

                    objective = @(pars) -logLikelihoodOfRelFreq(accuracies, N, ...
                    outselect(1, @metaControlModelRecallOverrideNoGo, pars(1), pars(2), gamma, load, pars(3), ...
                    pars(4),m,random_inhibition,p_cue_probe,p_slip));

               elseif isNoGo == 0
                    modelType = @metaControlModelRecallOverride;

                    objective = @(pars) -logLikelihoodOfRelFreq(accuracies, N, ...
                    outselect(1, @metaControlModelRecallOverride, pars(1), pars(2), gamma, load, pars(3), ...
                    pars(4),m,random_inhibition,p_cue_probe,p_slip));

              end
           end
%%  %%%%%%% Model 2 - No Inhibition 
        if modelName == "NoInhibition"
             if isNoGo == 1
                    modelType = @metaControlModelNoInhibitionNoGo;

                    objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
                            outselect(1,@metaControlModelNoInhibitionNoGo, pars(1), ...   % pars(2) = alpha for A and X trials! 
                                        pars(2), gamma,load,pars(3), ...                  % pars(3) = control_cost;
                                        pars(4),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                             % output of metaControlModel = predicted accuracies          % pars(5) = lambda (interference of cognitive load);

             elseif isNoGo == 0
                    modelType = @metaControlModelNoInhibition;

                    objective = @(pars) -logLikelihoodOfRelFreq( accuracies, N, ...       % pars(1) = alpha for AY, BX, BY trials; 
                            outselect(1,@metaControlModelNoInhibition, pars(1), ...       % pars(2) = alpha for A and X trials! 
                                        pars(2), gamma,load,pars(3), ...                  % pars(3) = control_cost;
                                        pars(4),m,random_inhibition,p_cue_probe,p_slip)); % pars(4) = delta_t;      
                             % output of metaControlModel = predicted accuracies          % pars(5) = lambda (interference of cognitive load);

             end
        end
    
%%      Fit Models 4 (4 params) %%%  
            % pars(1) = alpha
            % pars(2) = alphaAX
            % pars(3) = delta_t
            % pars(4) = lambda 
        [pars,neg_ll]=fmincon(objective,[2,2,2,0.1], [], ...
        [],[],[],[0;0;0;lambda_min],[10;10;10;1/3],[], options);

%%      Function output - parameters      
        [accs, p_intentions, optimal_cs, p_recalls] = ...
        modelType(pars(1), pars(2), gamma, load, pars(3), pars(4), ...
        m, random_inhibition, p_cue_probe,p_slip);
        npars = numel(pars);
    
         % adding control cost as 0 in the third column
         B = [0];
         pars_temp = [pars(:,1:2) B  pars(:,3:end)];
         pars = pars_temp;
        
    end            
    
    % Fit Measures
    ll = -neg_ll;
    bic = npars*log(trials)-2*ll;

end