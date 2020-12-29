%% Defining Proactive and Reactive predicted distributions
% Proactive - AX, AY, BX and BY trials
p_X_habit = pAX/(pAX+pBX); 
p_Y_habit = 1; % CHANGE THIS IF NO GO??

for l=1:numel(load)
    p_correct_intention_proactive(l,:) = [pAX/pA * (1 -0.05*(load(l)-1)), ...
                                          1-pAX/(pAX+pAY) * (1 -0.05*(load(l)-1)), ...
                                          (pBX+pBY)/pB * (1 -0.05*(load(l)-1)), ...
                                          (pBX+pBY)/pB * (1 -0.05*(load(l)-1))];
end      

% Reactive - AX, AY, BX and BY trials
p_correct_intention_reactive = [p_X_habit, ...
                                p_Y_habit, ...
                                1-p_X_habit, ...
                                p_Y_habit];
                            
%% Probability to PRESS the right button
p_correct_proactive = p_correct_intention_proactive*(1-p_slip)+(1-p_correct_intention_proactive)*p_slip;
p_correct_reactive  = p_correct_intention_reactive*(1-p_slip)+(1-p_correct_intention_reactive)*p_slip;
p_correct_no_goal   = [p_X_habit,p_Y_habit,1-p_X_habit,p_Y_habit]*(1-p_slip); % Now this is essentially the same as S


%%
A_trials = [1:2,5:6]; B_trials = [3:4,7:8];
p_A_trials = sum(experiment.blocks(1).p_trial_type(1:2));
p_B_trials = sum(experiment.blocks(1).p_trial_type(3:4));

% Predict response distributions to compare when measuring proactivity and reactivity
% not being proactive (no goal) - Herrnstein's law
%p_correct_intention_no_stim = [pAX/(pAX+pAY),1-pAX/(pAX+pAY),1, 1]; 
% for BX and BY trials the proactive intention is to say no and this is always correct

p_correct_proactive_no_stim = p_correct_reactive; %p_correct_intention_no_stim*(1-p_slip)+...
   % p_slip*(1-p_correct_intention_no_stim); % AX, AY, BX and BY

% not being reactive (stimuli don't influence behavior) - respond affirmatively pAX out of total trials regardless of which stimulus is presented.
% probability of an affirmative response given habitual control p(AX)
p_AX_reactive_no_stim = pAX; 
p_correct_reactive_no_stim = p_AX_reactive_no_stim*[1,0,0,0]*(1-p_slip)+...
    p_slip*(1-p_AX_reactive_no_stim)*[0,1,1,1];%

% Probability for pressing the right button using (or not) a proactive, reactive or habitual strategy for for each trial_type
% SA pair
p_AS_proactive = [experiment.blocks(1).p_trial_type.*p_correct_proactive, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_proactive)];
p_AS_reactive = [experiment.blocks(1).p_trial_type.*p_correct_reactive, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_reactive)];
p_AS_no_goal = [experiment.blocks(1).p_trial_type.*p_correct_no_goal, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_no_goal)];

% Proability if the current stimulus had no effect on their immediate behavior
p_AS_no_stimulus_proactive = [experiment.blocks(1).p_trial_type.*p_correct_proactive_no_stim, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_proactive_no_stim)];
p_AS_no_stimulus_reactive = [experiment.blocks(1).p_trial_type.*p_correct_reactive_no_stim, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_reactive_no_stim)];

% Probability of being proactive/reactive given A/B cues
p_AS_proactive_A=1/p_A_trials*p_AS_proactive(A_trials); % p(proactive|A)
p_AS_reactive_A= 1/p_A_trials*p_AS_reactive(A_trials); % p(reactive|A)
p_AS_proactive_B=1/p_B_trials*p_AS_proactive(B_trials); % p(proactive|A)
p_AS_reactive_B= 1/p_B_trials*p_AS_reactive(B_trials); % p(reactive|A)


%% Measuring individual proactivity and reactivity in Maki Data

data_AXCPT = table2array(DataAXCPT(:,[2:3,6:13]));
accuracies = data_AXCPT(:,3:6);
RTs = data_AXCPT(:,7:end);
nr_subjets=size(DataAXCPT,1);
trials = 150;

for s=1:nr_subjets
    for tt=1:4
        prob = experiment.blocks(1).p_trial_type(tt);
        inds = [tt,tt+4];
        acc = max(0.0001,min(0.9999,accuracies(s,tt)));
        probs = [acc,1-acc];
        GD_by_participant_and_tt(s,tt)=MeasureGoalDirectedness(...
            probs,1/prob*p_AS_no_goal(inds),1:2);
 
    end
    
    accuracy_by_participant(s) = dot(accuracies(s,:),experiment.blocks(1).p_trial_type);
    avg_RT_by_participant(s) = dot(RTs(s,:),experiment.blocks(1).p_trial_type);
    
    accs = max(0.00001,min(0.99999,accuracies(s,:)));    
    p_SA = [experiment.blocks(1).p_trial_type.*accs,...
        experiment.blocks(1).p_trial_type.*(1-accs)];
    GD_by_participant(s) = MeasureGoalDirectedness(...
            p_SA,p_AS_no_goal,1:8);
    reactivity_by_participant(s) = MeasureReactivity(...
            p_SA,p_AS_no_stimulus_reactive,1:8);         
       
end
