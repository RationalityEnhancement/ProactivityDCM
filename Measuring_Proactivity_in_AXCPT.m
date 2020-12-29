%% Measuring Proactivity and Reactivity(IG) in AXCPT %%
% importing data
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');
import_data_AXCPT;

%% Predictions for proactivity in Maki data - AX-CPT 70-10-10-10
pAX = 0.7; pAY = 0.1; pBX = 0.1; pBY = 0.1;
p_cue_probe = [pAX,pAY,pBX,pBY];
experiment.blocks(1).p_trial_type = p_cue_probe;
pA = pAX+pAY/(pAX+pAY+pBX+pBY); 
pB = pBX+pBY/(pAX+pAY+pBX+pBY);
p_X_habit = pAX/(pAX+pBX); 
p_Y_habit = 1; 
p_slip = 0.0125;

load = 1;
isNoGo = 0;
m = 1;

%% Defining Proactive and Reactive predicted distributions
% Proactive - AX, AY, BX and BY trials

for l=1:numel(load)
    p_correct_intention_proactive(l,:) = [pAX/pA * (1 -0.05*(load(l)-1)), ...
                                          1-pAX/(pAX+pAY) * (1 -0.05*(load(l)-1)), ...
                                          (pBX+pBY)/pB * (1 -0.05*(load(l)-1)), ...
                                          (pBX+pBY)/pB * (1 -0.05*(load(l)-1))]
end      

% Reactive - AX, AY, BX and BY trials
p_correct_intention_reactive = [p_X_habit, ...
                                p_Y_habit, ...
                                1-p_X_habit, ...
                                p_Y_habit];
                            
%% Probability to PRESS the right button
p_correct_proactive = p_correct_intention_proactive*(1-p_slip)+(1-p_correct_intention_proactive)*p_slip;
p_correct_reactive  = p_correct_intention_reactive*(1-p_slip)+(1-p_correct_intention_reactive)*p_slip;
p_correct_no_goal   = [p_X_habit,p_Y_habit,1-p_X_habit,p_Y_habit]*(1-p_slip); 

%%
A_trials = [1:2,5:6]; B_trials = [3:4,7:8];
p_A_trials = sum(experiment.blocks(1).p_trial_type(1:2));
p_B_trials = sum(experiment.blocks(1).p_trial_type(3:4));

%% Predict response distributions to compare when measuring Goal Directedness and Reactivity
p_correct_proactive_no_stim = p_correct_reactive; 
p_AX_reactive_no_stim = pAX; 
p_correct_reactive_no_stim = p_AX_reactive_no_stim*[1,0,0,0]*(1-p_slip)+...
    p_slip*(1-p_AX_reactive_no_stim)*[0,1,1,1];%

%% Probability for pressing the right button using (or not) a proactive, reactive or habitual strategy for for each trial_type
% SA pair
p_AS_proactive = [experiment.blocks(1).p_trial_type.*p_correct_proactive, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_proactive)];
p_AS_reactive = [experiment.blocks(1).p_trial_type.*p_correct_reactive, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_reactive)];
p_AS_no_goal = [experiment.blocks(1).p_trial_type.*p_correct_no_goal, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_no_goal)];

%% Proability if the current stimulus had no effect on their immediate behavior
p_AS_no_stimulus_proactive = [experiment.blocks(1).p_trial_type.*p_correct_proactive_no_stim, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_proactive_no_stim)];
p_AS_no_stimulus_reactive = [experiment.blocks(1).p_trial_type.*p_correct_reactive_no_stim, ...
    experiment.blocks(1).p_trial_type.*(1-p_correct_reactive_no_stim)];

%% Probability of being proactive/reactive given A/B cues
p_AS_proactive_A=1/p_A_trials*p_AS_proactive(A_trials); % p(proactive|A)
p_AS_reactive_A= 1/p_A_trials*p_AS_reactive(A_trials); % p(reactive|A)
p_AS_proactive_B=1/p_B_trials*p_AS_proactive(B_trials); % p(proactive|A)
p_AS_reactive_B= 1/p_B_trials*p_AS_reactive(B_trials); % p(reactive|A)

%% Proactivity and Reactivity (as formally defined) for each of Proactive, Reactive and Habitual Strategies 

% Proactivity of proactive control
proactivity_of_proactive_control=MeasureGoalDirectedness(p_AS_proactive,p_AS_no_goal,1:8) % overall
proactivity_of_proactive_control_A=MeasureGoalDirectedness(1/p_A_trials*p_AS_proactive(A_trials),1/p_A_trials*p_AS_no_goal(A_trials),1:4) % A trials
proactivity_of_proactive_control_B=MeasureGoalDirectedness(1/p_B_trials*p_AS_proactive(B_trials),1/p_B_trials*p_AS_no_goal(B_trials),5:8) % B trials

% Proactivity of reactive control
proactivity_of_reactive_control=MeasureGoalDirectedness(p_AS_reactive,p_AS_no_goal,1:8) % overall
proactivity_of_reactive_control_A=MeasureGoalDirectedness(1/p_A_trials*p_AS_reactive(A_trials),1/p_A_trials*p_AS_no_goal(A_trials),1:4) % A trials
proactivity_of_reactive_control_B=MeasureGoalDirectedness(1/p_B_trials*p_AS_reactive(B_trials),1/p_B_trials*p_AS_no_goal(B_trials),5:8)% B trials

% Reactivity of proactive and reactive control 
reactivity_of_proactive_control=MeasureReactivity(p_AS_proactive,p_AS_no_stimulus_proactive,1:8) % overall
reactivity_of_reactive_control=MeasureReactivity(p_AS_reactive,p_AS_no_stimulus_reactive,1:8) % overall

%% Plot formal measure of proactivity and reactivity of proactive and reactive control
figure(),
subplot(1,2,1)
bar([proactivity_of_reactive_control,proactivity_of_proactive_control])
ylim([0,1])
ylabel('Goal Directedness (KL)','FontSize',16)
set(gca,'XTickLabels',{'Habitual Control','Proactive Control'},'FontSize',16,'XTickLabelRotation',45)
subplot(1,2,2)
bar([reactivity_of_reactive_control,reactivity_of_proactive_control])
ylabel('Reactivity (KL)','FontSize',16)
set(gca,'XTickLabels',{'Habitual Control','Proactive Control'},'FontSize',16,'XTickLabelRotation',45)



%% Measuring Proactivity and Reactivity (KL) in Mäki data
% total accuracies regardless of condition
accuracies_by_trial_type = [0.9912,0.8485,0.8991,0.9875]; %AX, AY, BX, BY

N_participants_total = 266;
N_trials_total = 150;
N=experiment.blocks(1).p_trial_type*N_participants_total*N_trials_total;


%% Proactivity based on people's observed accuracy (aggregated)
p_AS_people = [accuracies_by_trial_type.*experiment.blocks(1).p_trial_type,...
    (1-accuracies_by_trial_type).*experiment.blocks(1).p_trial_type];

proactivity_of_people=MeasureGoalDirectedness(p_AS_people,p_AS_no_goal,1:8);
proactivity_A = MeasureGoalDirectedness(1/p_A_trials*p_AS_people(A_trials),1/p_A_trials*p_AS_no_goal(A_trials),1:4);
proactivity_B = MeasureGoalDirectedness(1/p_B_trials*p_AS_people(B_trials),1/p_B_trials*p_AS_no_goal(B_trials),5:8);
reactivity_of_people=MeasureReactivity(p_AS_people,p_AS_no_stimulus_proactive,1:8);

%% Proactivity and parameters by condition (reward x cognitive load) - aggregated
N_by_condition(1,:) = [47,42,42];
N_by_condition(2,:) = [45,45,45];
m=1;

for i = 1:length(N_by_condition(1,:)) % cognitive load conditions
      
      % No reward
      N=N_by_condition(1,i)*N_trials_total;
    
      accuracies_temp = accuracies_no_reward(i,:); 
      p_AS_temp = [accuracies_temp.*experiment.blocks(1).p_trial_type,...
    (1-accuracies_temp).*experiment.blocks(1).p_trial_type];  
      proactivity_by_condition(1,i) = MeasureGoalDirectedness(p_AS_temp,p_AS_no_goal,1:8);
      % p(intention), p(inhibition) and p(recall) by condition
      parameters_by_condition(1,:,i) = outselect([1], @fitProcessModel_RecallOverride, accuracies_temp, i, N, m,p_cue_probe,p_slip, isNoGo)
      
      % parameters by condition and cue type
      p_AS_A = 1/p_A_trials*p_AS_temp(A_trials);
      p_AS_B = 1/p_B_trials*p_AS_temp(B_trials);
     
    
      % proactivity by condition and cue type
      proactivity_by_condition_A(1,i) = MeasureGoalDirectedness(1/p_A_trials*p_AS_temp(A_trials),1/p_A_trials*p_AS_no_goal(A_trials),1:4);
      proactivity_by_condition_B(1,i) = MeasureGoalDirectedness(1/p_B_trials*p_AS_temp(B_trials),1/p_B_trials*p_AS_no_goal(B_trials),5:8);

      for tt=1:4 %loop over cue-probe trial types
          inds=[tt,tt+4]; prob=experiment.blocks(1).p_trial_type(tt);
          proactivity_by_condition_and_trial_type(1,i,tt)=...
              MeasureGoalDirectedness(1/prob*p_AS_temp(inds),1/prob*p_AS_no_goal(inds),1:2);
      end
      
      % Reward
      accuracies_temp = accuracies_with_reward(i,:);
      N=N_by_condition(2,i)*N_trials_total*experiment.blocks(1).p_trial_type;
      p_AS_temp = [accuracies_temp.*experiment.blocks(1).p_trial_type,...
    (1-accuracies_temp).*experiment.blocks(1).p_trial_type];      
      
      proactivity_by_condition(2,i) = MeasureGoalDirectedness(p_AS_temp,p_AS_no_goal,1:8);
    

      A_trials = [1:2,5:6]; B_trials = [3:4,7:8];
      p_A_trials = sum(experiment.blocks(1).p_trial_type(1:2));
      p_B_trials = sum(experiment.blocks(1).p_trial_type(3:4));
      
      p_AS_A=1/p_A_trials*p_AS_temp(A_trials);
      p_AS_B=1/p_B_trials*p_AS_temp(B_trials);
      
      p_no_goal_A=1/p_A_trials*p_AS_no_goal(A_trials);
      proactivity_by_condition_A(2,i) = MeasureGoalDirectedness(p_AS_A,p_no_goal_A,1:4);
      proactivity_by_condition_B(2,i) = MeasureGoalDirectedness(1/p_B_trials*p_AS_temp(B_trials),1/p_B_trials*p_AS_no_goal(B_trials),5:8);
      
      
      for tt=1:4 %loop over trial types
          inds=[tt,tt+4]; prob=experiment.blocks(1).p_trial_type(tt);
          proactivity_by_condition_and_trial_type(2,i,tt)=...
          MeasureGoalDirectedness(1/prob*p_AS_temp(inds),1/prob*p_AS_no_goal(inds),1:2);
          

      end
end

proactivity_by_reward = mean(mean(proactivity_by_condition_and_trial_type,3),2);
proactivity_by_load = mean(mean(proactivity_by_condition_and_trial_type,3),1);


%% Measuring individual Goal Directedness and Reactivity in Maki Data

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
        proactivity_by_participant_and_tt(s,tt)=MeasureGoalDirectedness(...
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

%% Proactivity between reward conditions
[mean(GD_by_participant(reward==0)), mean( GD_by_participant(reward==1))]
[std(GD_by_participant(reward==0)), std( GD_by_participant(reward==1))]
[h,p,ci,stats] = ttest2(GD_by_participant(reward==0),GD_by_participant(reward==1)) 

%% Descriptive Statistics for formal measures of proactivity and reactivity (individual level) 
mean_pro=mean(GD_by_participant)
std_pro=std(GD_by_participant)
mean_re=mean(reactivity_by_participant)
std_re=std(reactivity_by_participant)
[h_re,p_re,ci_re,stats_re]=ttest(reactivity_by_participant)
[h_pro,p_pro,ci_pro,stats_pro]=ttest(GD_by_participant)

% Differences between conditions for Goal Directedness (KL) 
[h,p] = ttest2(GD_by_participant(1:10), GD_by_participant(11:20), 'Vartype','unequal')


%% Plot Individual differences in proactivity
figure(),
subplot(1,2,1)
hist(GD_by_participant(:))
xlabel('Proactivity','FontSize',16)
ylabel('Frequency','FontSize',16)
subplot(1,2,2)
hist(reactivity_by_participant(:))
xlabel('Reactivity','FontSize',16)
ylabel('Frequency','FontSize',16)

% Descriptive Statistics for individual differences in proactivity
mean(GD_by_participant(:))
std(GD_by_participant(:))
min(GD_by_participant(:))
max(GD_by_participant(:))
range(GD_by_participant(:))

%% Correlation of KL measures and traditional proactive control measures
% Correlations between measures of proactivity
% Correction for error rates - error rate = (number of errors + 0.5)/(number of trials + 1) Braver 2009
errors(:,[1:4]) = 1-accuracies(:,[1:4]);
errors(:,:) = (errors(:,:)*trials + 0.5)./(trials + 1);
PBIerr = (errors(:,2)-errors(:,3))./(errors(:,2)+errors(:,3)); %(AY - BX)/(AY + BX)
dcontext = accuracies(:,1) - errors(:,3); % Hit(AX) - FA(BX)
Acuebias = (accuracies(:,1) + errors(:,2))/2; % Hit(AX) + FA(AY)/2
PBIrt = (data_AXCPT(:,8)- data_AXCPT(:,9))./(data_AXCPT(:,8) + data_AXCPT(:,9));%10-AX; 11-AY; 12-BX; 13-BY
PBIcomp = (PBIerr + PBIrt)/2;
meanRT = (data_AXCPT(:,7) + data_AXCPT(:,8) + data_AXCPT(:,9) + data_AXCPT(:,10))./4;

M = [reactivity_by_participant(:), GD_by_participant(:), accuracy_by_participant(:), meanRT(:), ...
    dcontext(:), Acuebias(:), PBIerr(:), PBIrt(:), PBIcomp(:)]; %avg_RT_by_participant(:), PBIrt(:), PBIcomp(:)];
[cor,p]=corr(M)

%% Goal Directedness (KL) - Predictions for different p(intention) and p(recall)
p_intention = linspace(0,1,101);
p_recall = linspace(0,1,101);


for i=1:length(p_intention)
    for r=1:length(p_recall)
        
    accuracies_across_intention_recall(i,:,r) = outselect(1, @processModelRecallOverride, p_intention(i), p_recall(r),load,m,p_cue_probe,p_slip);
    
    p_AS_across_intention_recall(i,:,r) = [experiment.blocks(1).p_trial_type.*accuracies_across_intention_recall(i,:,r),...
        experiment.blocks(1).p_trial_type.*(1-accuracies_across_intention_recall(i,:,r))];
        
    proactivity_across_intention_recall(i,r) = MeasureGoalDirectedness(p_AS_across_intention_recall(i,:,r),p_AS_no_goal,1:8);
    reactivity_across_intention_recall(i,r) = MeasureReactivity(p_AS_across_intention_recall(i,:,r),p_AS_no_stimulus_reactive,1:8);
    end
end


%% Plot Proactivity and Reactivity (KL) across diffrent p(intention) and p(recall)
figure()
subplot(1,2,1)
mesh(p_intention, p_recall, proactivity_across_intention_recall)
view(325, 20)
title('Goal Directedness (KL) across p_{recall} and p_{intention}')
xlabel('p_{recall}') 
ylabel('p_{intention}'); zlabel('Goal Directedness (KL)')
xticks(linspace(0,1,6)); yticks(linspace(0,1,6))

subplot(1,2,2)
mesh(p_intention, p_recall, reactivity_across_intention_recall)
view(250, 20)
title('Reactivity (KL) across p_{recall} and p_{intention}')
xlabel('p_{recall}') 
ylabel('p_{intention}'); zlabel('Reactivity (KL)')
xticks(linspace(0,1,6)); yticks(linspace(0,1,6))