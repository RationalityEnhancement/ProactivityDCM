function [predicted_accs, p_intentions,  p_recalls]= ...
    processModelRecallOverride(p_intention, p_recall, load,m,p_cue_probe,p_slip)

lambda = 0.05;

cues={'A','A','B','B'};
probes={'X','Y','X','Y'};

pAX = p_cue_probe(1);
pAY = p_cue_probe(2);
pBX = p_cue_probe(3);
pBY = p_cue_probe(4);

% probability to not press the button that correspond with the choice
p_random_error=p_slip;

% probability to choose the correct response according to Herrnstein's Matching Law
p_correct_habit=[pAX/(pAX+pBX), 1, pBX/(pAX+pBX), 1]*(1-p_random_error)...
    +p_random_error*[1-pAX/(pAX+pBX), 0, 1-pBX/(pAX+pBX),0]; %[7/8,7/8,1/8,7/8];

% probability to choose the correct response for proactive control
p_correct_proactive = [pAX/(pAX+pAY) * (1 - lambda*(load-1)),... % AX
    (1-pAX/(pAX+pAY)) * (1 - lambda*(load-1)),... % AY
    1 * (1 - lambda*(load-1)),... % BX
    1 * (1 - lambda*(load-1)) ... % BY
    ]*(1-p_random_error)...
    +p_random_error*[1-(pAX/(pAX+pAY))* (1 - lambda*(load-1)),... 
    pAX/(pAX+pAY)* (1 - lambda*(load-1)),... 
    0* (1 - lambda*(load-1)), ... 
    0* (1 - lambda*(load-1))];

% probability to choose the correct response given recall
p_correct_recall = [m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1))]*(1-p_random_error)...
+ p_random_error*[1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1)))];

for s=1:numel(cues)
    
    cue = cues{s}; probe=probes{s};
    
    % parameters for each trial type
    p_intentions(1,s) = p_intention;
    p_recalls(1,s) = p_recall;
    
     
% Process Model Predicted Accuracies
predicted_accs(1,s) = p_intention*(1-p_recall)*p_correct_proactive(s) + ...
    p_intention*p_recall*p_correct_recall(s) + ...
    (1-p_intention)*p_recall*p_correct_recall(s) + ...
    (1-p_intention)*(1-p_recall)*p_correct_habit(s);


end

end