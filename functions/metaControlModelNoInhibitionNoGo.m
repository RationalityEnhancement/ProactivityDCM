function [predicted_accs, p_intentions, optimal_cs, p_recalls] = ...
    metaControlModelNoGo(alpha,alphaAX,gamma,load,delta_t,lambda,m,random_inhibition,p_cue_probe,p_slip)

cues={'A','A','B','B','A','B'};
probes={'X','Y','X','Y','N','N'};

p_random_error=p_slip;

pAX = p_cue_probe(1);
pAY = p_cue_probe(2);
pBX = p_cue_probe(3);
pBY = p_cue_probe(4);
pAN = p_cue_probe(5);
pBN = p_cue_probe(6);

% All sensitive to the probe
p_correct_habit=[pAX/(pAX+pBX), 1, pBX/(pAX+pBX), 1, 1, 1]*(1-p_random_error) ...
    + p_random_error*[1-pAX/(pAX+pBX),0,1-pBX/(pAX+pBX),0,0,0]; 

if not(exist('p_cue_probe','var'))
    p_given_A=[pAX/(pAX+pAY), pAY/(pAX+pAY), 0, 0];
    p_given_B=[0, 0, pBX/(pBX+pBY), pBX/(pBX+pBY)];
    p_given_X=[pAX/(pAX+pBX), 0, pBX/(pAX+pBX), 0]; 
    p_given_Y=[0, pAY/(pAY+pBY), 0, pBY/(pAY+pBY)]; 
    
 
else
    with_A=[1,1,0,0,1,0];
    with_B=[0,0,1,1,0,1];
    with_X=[1,0,1,0,0,0];
    with_Y=[0,1,0,1,0,0];
    with_N=[0,0,0,0,1,1];
    
    p_A=dot(p_cue_probe,with_A);
    p_B=dot(p_cue_probe,with_B);
    p_X=dot(p_cue_probe,with_X);
    p_Y=dot(p_cue_probe,with_Y);
    p_N=dot(p_cue_probe,with_N);
    
    p_given_A=p_cue_probe.*with_A/p_A;
    p_given_B=p_cue_probe.*with_B/p_B;
    p_given_X=p_cue_probe.*with_X/p_X;
    p_given_Y=p_cue_probe.*with_Y/p_Y; 
    p_given_N=p_cue_probe.*with_N/p_N;
  
end

p_correct_proactive =  [pAX/(pAX+pAY) * (1 - lambda*(load-1)),... %AX
    (1-pAX/(pAX+pAY)) * (1 - lambda*(load-1)),...%AY
    (pBX+pBY)/(pBX+pBY+pBN) * (1 - lambda*(load-1)), ... %BX
    (pBX+pBY)/(pBX+pBY+pBN) * (1 - lambda*(load-1)), ...%BY
    pAN/(pAX+pAY+pAN) * (1 - lambda*(load-1)), ... %AN
    pBN/(pBX+pBY+pBN) * (1 - lambda*(load-1)), ... %BN
    ]*(1-p_random_error)...
    +p_random_error*[1-pAX/(pAX+pAY) * (1 + lambda*(load-1)),...
    pAX/(pAX+pAY) * (1 + lambda*(load-1)),...
    1-(pBX+pBY)/(pBX+pBY+pBN) * (1 + lambda*(load-1)),...
    1-(pBX+pBY)/(pBX+pBY+pBN) * (1 + lambda*(load-1)),...
    1-pAN/(pAX+pAY+pAN) * (1 + lambda*(load-1)),...
    1-pBN/(pBX+pBY+pBN) * (1 + lambda*(load-1))];

% Benefit of setting and intention
delta_acc = p_correct_proactive-p_correct_habit;

% p(correct response | recall) 
p_correct_recall = [m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1))]*(1-p_random_error)...
+ p_random_error*[1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1)))];

% Benefit of recalling
delta_acc_recall = p_correct_recall-p_correct_habit;

% Net benefit
E_delta_acc_A = dot(delta_acc,p_given_A);
E_delta_acc_B = dot(delta_acc,p_given_B);
E_delta_acc_X = dot(delta_acc,p_given_X);
E_delta_acc_Y = dot(delta_acc,p_given_Y);
E_delta_acc_N = dot(delta_acc,p_given_N);

E_delta_acc_recall_A = dot(delta_acc_recall,p_given_A);
E_delta_acc_recall_B = dot(delta_acc_recall,p_given_B);
E_delta_acc_recall_X = dot(delta_acc_recall,p_given_X);
E_delta_acc_recall_Y = dot(delta_acc_recall,p_given_Y);
E_delta_acc_recall_N = dot(delta_acc_recall,p_given_N);

for s=1:numel(cues)
    
    cue = cues{s}; probe=probes{s};
    
    %Step 1: intention setting
    if strcmp(cue,'A')
        net_benefit = E_delta_acc_A*alphaAX+delta_t-gamma; 
    elseif strcmp(cue,'B')
        net_benefit = E_delta_acc_B*alpha+delta_t-gamma;
    end
    p_intention = sigmoid(net_benefit);
        
    % Step 2: Decide to recall or not 
    if strcmp(probe,'X')
        net_benefit_recall = E_delta_acc_recall_X*alphaAX-delta_t-gamma;
     elseif strcmp(probe,'Y')
        net_benefit_recall = E_delta_acc_recall_Y*alpha-delta_t-gamma;
     elseif strcmp(probe,'N')
        net_benefit_recall = E_delta_acc_recall_N*alpha-delta_t-gamma;
    end
    p_recall = sigmoid(net_benefit_recall);
   
    % Cost-Benefit analysis parameters for each trial type
    optimal_cs(1,s) = 0; %optimal_cs(1,s) = optimal_c;
    p_intentions(1,s) = p_intention;
    p_recalls(1,s) = p_recall;
    
    % Predicted accuracies
    predicted_accs(1,s) = p_intention*p_correct_proactive(s) + ...
    (1-p_intention)*p_recall*p_correct_recall(s) + ...
    (1-p_intention)*(1-p_recall)*p_correct_habit(s);
    
   
end

end