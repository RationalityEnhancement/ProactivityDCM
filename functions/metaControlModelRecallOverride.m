function [predicted_accs, p_intentions, optimal_cs, p_recalls] = ...
metaControlModelRecallOverride(alpha, alphaAX, gamma,load,delta_t,lambda,m,random_inhibition,p_cue_probe,p_slip)

% alpha = reward 
% gamma = cost of setting intention and recalling
% delta = control cost
% delta_t = reward for fast responses
% lambda = cognitive load interference

cues={'A','A','B','B'};
probes={'X','Y','X','Y'};

p_random_error=p_slip;

pAX = p_cue_probe(1);
pAY = p_cue_probe(2);
pBX = p_cue_probe(3);
pBY = p_cue_probe(4);

p_correct_habit=[pAX/(pAX+pBX), 1, pBX/(pAX+pBX), 1]*(1-p_random_error)...
    +p_random_error*[1-pAX/(pAX+pBX), 0, 1-pBX/(pAX+pBX),0]; 

if not(exist('p_cue_probe','var'))
    p_given_A=[pAX/(pAX+pAY), pAY/(pAX+pAY), 0, 0];
    p_given_B=[0, 0, pBX/(pBX+pBY), pBX/(pBX+pBY)];
    p_given_X=[pAX/(pAX+pBX), 0, pBX/(pAX+pBX), 0]; 
    p_given_Y=[0, pAY/(pAY+pBY), 0, pBY/(pAY+pBY)]; 
    
    
else
    with_A=[1,1,0,0];
    with_B=[0,0,1,1];
    with_X=[1,0,1,0];
    with_Y=[0,1,0,1];
    
    p_A=dot(p_cue_probe,with_A);
    p_B=dot(p_cue_probe,with_B);
    p_X=dot(p_cue_probe,with_X);
    p_Y=dot(p_cue_probe,with_Y);
    
    p_given_A=p_cue_probe.*with_A/p_A;
    p_given_B=p_cue_probe.*with_B/p_B;
    p_given_X=p_cue_probe.*with_X/p_X;
    p_given_Y=p_cue_probe.*with_Y/p_Y;    
    
    
end

p_correct_proactive = [pAX/(pAX+pAY) * (1 - lambda*(load-1)),...
    (1-pAX/(pAX+pAY)) * (1 - lambda*(load-1)),... 
    1 * (1 - lambda*(load-1)),... 
    1 * (1 - lambda*(load-1)) ... 
    ]*(1-p_random_error)...
    +p_random_error*[1-(pAX/(pAX+pAY))* (1 - lambda*(load-1)),...
    pAX/(pAX+pAY)* (1 - lambda*(load-1)),...
    0* (1 - lambda*(load-1)), ... 
    0* (1 - lambda*(load-1))];

% Benefit of setting and intention
delta_acc = p_correct_proactive-p_correct_habit;

% p(correct response | recall) 
p_correct_recall = [m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1)), m * (1 - lambda*(load-1))]*(1-p_random_error)...
+ p_random_error*[1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1))), 1-(m * (1 - lambda*(load-1)))];

% Benefit of recalling
delta_acc_recall = p_correct_recall-p_correct_habit;

% Net benefit
E_delta_acc_A = dot(delta_acc,p_given_A);
E_delta_acc_B = dot(delta_acc,p_given_B);
E_delta_acc_X = dot(delta_acc,p_given_X);
E_delta_acc_Y = dot(delta_acc,p_given_Y);

E_delta_acc_recall_A = dot(delta_acc_recall,p_given_A);
E_delta_acc_recall_B = dot(delta_acc_recall,p_given_B);
E_delta_acc_recall_X = dot(delta_acc_recall,p_given_X);
E_delta_acc_recall_Y = dot(delta_acc_recall,p_given_Y);


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
    end
    p_recall = sigmoid(net_benefit_recall);
    
    % Cost-Benefit analysis parameters for each trial type
    optimal_cs(1,s) = 0; %optimal_c;
    p_intentions(1,s) = p_intention;
    p_recalls(1,s) = p_recall;
    
    % Predicted accuracies
        %1. p_intention*(1-p_inhibition)*p_cue_probe(s)
        %2. p_intention*p_inhibition*p_recall*p_correct_recall
        %3. p_intention*p_inhibition*(1-p_recall)*p_habit(s)
        %4. (1-p_intention)*p_recall*p_correct_recall
        %5. (1-p_intention)*(1-p_recall)*p_habit(s)
        
    predicted_accs(1,s) = p_intention*p_recall*p_correct_recall(s) + ...
        p_intention*(1-p_recall)*p_correct_proactive(s) + ...
        (1-p_intention)*p_recall*p_correct_recall(s) + ...
        (1-p_intention)*(1-p_recall)*p_correct_habit(s);
 
   
       
end

end