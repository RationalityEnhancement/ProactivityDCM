% DMC Process Model Fitting
function [pars,predicted_accs,ll,bic]= ...
fitProcessModel_RecallOverride(accuracies,load,trials,m,p_cue_probe,p_slip,is_noGo)
N = trials*p_cue_probe;
 
if is_noGo == 0
   
    % pars
        % p(intention)
        % p(recall)
    
    objective = @(pars) -logLikelihoodOfRelFreq(accuracies, N, outselect(1,@processModelRecallOverride,...
        pars(1),pars(2),load,m,p_cue_probe,p_slip));

    [pars,neg_ll]=fmincon(objective,[0.5; 0.5],[-1 0; 0 -1; 1 0; 0 1],[0;0;1;1]); 
    ll = -neg_ll;
    bic = numel(pars)*log(trials)-2*ll;

    [predicted_accs, p_intentions,  p_recalls] = ...
        processModelRecallOverride(pars(1),pars(2),load,m,p_cue_probe,p_slip);

elseif is_noGo == 1
    objective = @(pars) -logLikelihoodOfRelFreq(accuracies, N, outselect(1,@processModelNoGo,...
        pars(1),pars(2), load,m,p_cue_probe,p_slip))

    [pars,neg_ll]=fmincon(objective,[0.5; 0.5],[-1 0; 0 -1; 1 0; 0 1],[0;0;1;1]); 
    ll = -neg_ll;
    bic = numel(pars)*log(trials)-2*ll;

    [predicted_accs, p_intentions, p_recalls] = ...
        processModelRecallOverrideNoGo(pars(1),pars(2),load,m,p_cue_probe,p_slip);

    
end

end